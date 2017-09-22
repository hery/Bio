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

    init(json:Dictionary<String, Any>) {
        self.brand = json["Brand"] as? String
        self.name = json["Name"] as? String
        self.speedMax = json["SpeedMax"] as? Int
        self.cv = json["Cv"] as? Int
        self.currentSpeed = json["CurrentSpeed"] as? Int
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
}
