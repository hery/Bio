//
//  ViewModel.swift
//  Bio
//
//  Created by Hery Ratsimihah on 9/18/17.
//  Copyright © 2017 Ratsimihah. All rights reserved.
//

import UIKit
import RxSwift
import Starscream
import RxStarscream

// Logic

class ViewModel: NSObject {

    private let socket = WebSocket(url: URL(string: "wss://pbbouachour.fr/openSocket")!)
    private let disposeBag = DisposeBag()
    private let writeSubject = PublishSubject<String>()

    func initSocket(_ logger: UITextView) {
        self.observeEvents(logger)
    }

    func observeEvents(_ logTextView: UITextView) {
        socket.rx.response.subscribe(onNext: { (response: WebSocketEvent) in
            switch response {
                case .connected:
                    print("Connected")
                case .data(let data):
                    print("Got data \(data)")
                case .disconnected(let error):
                    print("Error \(error)")
                case .message(let msg):
                    print("Got message \(msg)")
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

    func sendJSON(message: [String: String]) {
        let jsonMessage = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        if let jsonMessage = jsonMessage {
            socket.write(data: jsonMessage)
        }
    }

    func getCarList() {
        // TODO: Remove
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "infos"
        payload["UserToken"] = 42

        var payloadPayload:Dictionary<String, Any> = [:]
        payloadPayload["Name"] = ["Wat"]
        payload["Payload"] = payloadPayload
    }
}
