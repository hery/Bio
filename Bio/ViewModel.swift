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

    // MARK: WebSocket Messages
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
        let payload = self.getCarListPayload()
        self.sendJSON(message: payload)
    }

    func startCar(_ name: String) {
        let payload = self.startCarSpeedPayload(name)
        self.sendJSON(message: payload)
    }

    func stopCar(_ name: String) {

    }

    func stopLastCar() {
        let payload = self.stopPreviousCarPayload()
        self.sendJSON(message: payload)
    }

    // MARK: Websocket Messages Utility
    func sendString(message: String) {
        socket.write(string: message)
    }

    func sendJSON(message: [String: Any]) {
        let jsonMessage = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        if let jsonMessage = jsonMessage {
            socket.write(data: jsonMessage)
        }
    }

    func getCarListPayload() -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "infos"
        payload["UserToken"] = 42
        return payload
    }

    func stopPreviousCarPayload() -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "stop"
        payload["UserToken"] = 42
        return payload
    }

    func startCarSpeedPayload(_ name: String) -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "start"
        payload["UserToken"] = 42

        var payloadPayload:Dictionary<String, Any> = [:]
        payloadPayload["Name"] = name
        payload["Payload"] = payloadPayload
        return payload
    }

    func stopCarPayload(_ name: String) -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "stop"
        payload["UserToken"] = 42

        var payloadPayload:Dictionary<String, Any> = [:]
        payloadPayload["Name"] = name
        payload["Payload"] = payloadPayload
        return payload
    }

    func parseCarsList(_ carsList: [Dictionary<String, Any>]) {
        if carsList.count < 1 {
            print("Invalid/empty car list payload")
            return
        }
        let keys = Set(carsList[0].keys)
        if (keys == Car.keys()) {
            let carsListArray = Car.carsFromJson(json: carsList)
            self.carsList.value = carsListArray
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
    }
}
