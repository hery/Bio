//
//  Car.swift
//  Bio
//
//  Created by Hery Ratsimihah on 9/21/17.
//  Copyright © 2017 Ratsimihah. All rights reserved.
//

import UIKit

class Car {

    var brand: String?
    var name: String?
    var speedMax: Int?
    var cv: Int?
    var currentSpeed: Int?
    var started = false

    init(json:Dictionary<String, Any>) {
        self.brand = json["Brand"] as? String
        self.name = json["Name"] as? String
        self.speedMax = json["SpeedMax"] as? Int
        self.cv = json["Cv"] as? Int
        self.currentSpeed = json["CurrentSpeed"] as? Int
    }

    class func printCarsDescription(_ cars: [Car]) {
        print("===")
        for car in cars {
            print("\(car.description()) (\(car.started))")
        }
        print("===")
    }

    class func carsFromJson(json: [Dictionary<String, Any>]) -> [Car] {
        var cars:[Car] = []
        for item in json {
            cars.append(Car(json: item))
        }
        return cars
    }

    class func keys() -> Set<String> {
        return Set(["Brand", "Name", "SpeedMax", "Cv", "CurrentSpeed"])
    }

    class func speedKeys() -> Set<String> {
        return Set(["Brand", "Name", "SpeedMax", "Cv", "CurrentSpeed"])
    }

    class func getCarListPayload() -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "infos"
        payload["UserToken"] = 42
        return payload
    }

    class func stopPreviousCarPayload() -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "stop"
        payload["UserToken"] = 42
        return payload
    }

    class func startCarSpeedPayload(_ name: String) -> Dictionary<String, Any> {
        var payload:Dictionary<String, Any> = [:]
        payload["Type"] = "start"
        payload["UserToken"] = 42

        var payloadPayload:Dictionary<String, Any> = [:]
        payloadPayload["Name"] = name
        payload["Payload"] = payloadPayload
        return payload
    }

    func description() -> String {
        let brand = self.brand != nil ? self.brand! : "Unknown brand"
        let name = self.name != nil ? self.name! : "Unknown model"
        return "\(brand) \(name)"
    }

    func speed() -> String {
        if let speed = self.currentSpeed {
            return "\(speed)km/h"
        }
        return "0km/h"
    }

    class func indexMap(_ fromCars:[Car]) -> Dictionary<String, Int> {
        var result:Dictionary<String, Int> = [:]
        for (index, car) in fromCars.enumerated() {
            if let name = car.name {
                result[name] = index
            }
        }
        return result
    }
}
