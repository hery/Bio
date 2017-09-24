//
//  ViewModel.swift
//  Bio
//
//  Created by Hery Ratsimihah on 9/18/17.
//  Copyright © 2017 Ratsimihah. All rights reserved.
//

import UIKit
import Starscream
import RxCocoa
import RxStarscream
import RxSwift


// Logic

class ViewModel: NSObject {

    private let socket = WebSocket(url: URL(string: "wss://pbbouachour.fr/openSocket")!)
    private let writeSubject = PublishSubject<String>()

    let disposeBag = DisposeBag()
    var carsList: Variable<[Car]> = Variable([])
    var currentCar: Car?
    var indexMap:Dictionary<String, Int>?

    // MARK: WebSocket Messages + Events
    func initSocket() {
        self.observeEvents()
    }

    func observeEvents() {
        socket.rx.response.subscribe(onNext: { (response: WebSocketEvent) in
            switch response {
                case .connected:
                    print("Connected.")
                    print("Getting cars list.")
                    self.getCarList()
                case .data(let data):
                    print("Got data \(data)")
                case .disconnected(let error):
                    print("Error \(String(describing: error))")
                case .message(let msg):
                    print("Got message\(msg)")
                    self.handleMessage(msg)
                case .pong:
                    print("Pong")
            }
        }, onError: { (error) in

        }, onCompleted: { 

        }).disposed(by: disposeBag)
        self.socket.connect()
    }

    func handleMessage(_ message: String) {
        guard let data = message.data(using: .utf8) else {
            print("Error converting message to data")
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("Error converting message data to JSON")
            return
        }

        // If it's a list, it has to be a list of cars
        if let carsList = json as? [Dictionary<String, Any>] {
            self.parseCarsList(carsList)
            return
        }

        // If it's a single item, it's a speed update
        if let carPayload = json as? Dictionary<String, Any> {
            self.parseCarSpeedPayload(carPayload)
            return
        }

        // We shouldn't get up to here
        print("Not sure what kind of payload we got here...")
        
    }

    func getCarList() {
        let payload = Car.getCarListPayload()
        self.sendJSON(message: payload)
    }

    func startCar(_ car: Car) {
        print("<Starting car \(car.description())>")
        guard let name = car.name else {
            print("Can't start car \(car.description()). Missing name.")
            return
        }

        if let _ = self.currentCar {
            // We stop the last car now or we won't be able
            // to stop it later
            self.stopLastCar()
        }

        let payload = Car.startCarSpeedPayload(name)
        self.sendJSON(message: payload)

        car.started = true
        self.currentCar = car
    }

    func stopLastCar() {
        print("Stopping last started car")
        let payload = Car.stopPreviousCarPayload()
        self.sendJSON(message: payload)

        if let indexMap = self.indexMap,
           let currentCar = self.currentCar,
           let name = currentCar.name,
           let index = indexMap[name] {
           self.carsList.value[index].started = false
        }

        self.currentCar = nil
    }

    // MARK: Websocket Messages Utility
    func sendString(message: String) {
        socket.write(string: message)
    }

    func sendJSON(message: [String: Any]) {
        print("Sending message \(message)")
        let jsonMessage = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        if let jsonMessage = jsonMessage {
            socket.write(data: jsonMessage)
        }
    }

    func parseCarsList(_ carsList: [Dictionary<String, Any>]) {
        if carsList.count < 1 {
            print("Invalid/empty car list payload")
            return
        }
        let keys = Set(carsList[0].keys)
        if (keys == Car.keys()) {
            self.carsList.value = Car.carsFromJson(json: carsList)
            self.indexMap = Car.indexMap(self.carsList.value)
        }
    }

    func parseCarSpeedPayload(_ message: Dictionary<String, Any>) {
    /**
        {
            "Brand":"Aston Martin",
            "Name":"Mini Cooper",
            "SpeedMax":180,
            "Cv":163,
            "CurrentSpeed":1.63}
        }
    */
        if let carName = message["Name"] as? String, let indexMap = self.indexMap {
            if let index = indexMap[carName] {
                // We need to persist the local value of `started`
                let oldCar = self.carsList.value[index]
                let newCar = Car(json: message)
                newCar.started = oldCar.started
                self.carsList.value[index] = newCar
            }
        }
    }
}
