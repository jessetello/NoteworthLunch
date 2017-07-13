//
//  NLRestaurant.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/7/17.
//  Copyright © 2017 jt. All rights reserved.
//

import Foundation
import CoreLocation

class NLRestaurant {
    
    var name:String?
    var address:String?
    var placeId:String?
    var rating:Double
    var priceLevel:Int
    var location:CLLocationCoordinate2D?
    var openNow = false
    
    init(placeData:[String:AnyObject]) {
        self.name = placeData["name"] as? String
        self.address = placeData["vicinity"] as? String
        self.placeId = placeData["place_id"] as? String
        self.rating = placeData["rating"] as? Double ?? 0
        self.priceLevel = placeData["price_level"] as? Int ?? 0
        
        if let opening = placeData["opening_hours"] as? [String: Any] {
            if let openNow = opening["open_now"] as? NSNumber {
                self.openNow = Bool(openNow)
            }
        }
       
        if let geometry = placeData["geometry"] as? [String: Any] {
            if let location = geometry["location"] as? [String: Double] {
                if let lat = location["lat"], let lng = location["lng"] {
                    self.location = CLLocationCoordinate2DMake(lat, lng)
                }
            }
        }
    }
}
