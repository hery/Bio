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
                    print("Connected. Getting cars list.")
                    self.getCarList()
                case .data(let data):
                    print("Got data \(data)")
                case .disconnected(let error):
                    print("Error \(String(describing: error))")
                case .message(let msg):
                    self.handleMessage(msg)
                case .pong:
                    print("Pong")
            }
        }, onError: { (error) in

        }, onCompleted: { 

        }).disposed(by: disposeBag)
        self.socket.connect()
    }

    func sendString(message: String) {
        socket.write(string: message)
    }

    func sendJSON(message: [String: Any]) {
        let jsonMessage = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        if let jsonMessage = jsonMessage {
            socket.write(data: jsonMessage)
        }
    }

    func getCarList() {
        let payload = self.getCarListPayload()
        self.sendJSON(message: payload)
    }

    func getCarListPayload() -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "infos"
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

    func stopPreviousCarPayload() -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "stop"
        payload["UserToken"] = 42
        return payload
    }

    func handleMessage(_ message: String) {
        // Try different deserialization methos since there's no message type key
        // in the server payload
        guard let data = message.data(using: .utf8) else {
            print("Error converting message to data")
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("Error converting message data to JSON")
            return
        }

        if let carsList = json as? [Dictionary<String, Any>] {
            // Proper type, still need to check for keys
            // try to parse cars list
            self.parseCarsList(carsList)
            return // if success
        }

        // We shouldn't get up to here
        print("Not sure what kind of payload we got here...")

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
}
