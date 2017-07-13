//
//  NLRestaurantViewModel.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/7/17.
//  Copyright © 2017 jt. All rights reserved.
//

import Foundation
import CoreLocation

protocol NLRestaurantViewModelDelegate: class {
    func restaurantsLoaded(searchedCoords:CLLocationCoordinate2D?)
    func locationFailure()
}

class NLRestaurantViewModel: NSObject {
    
    var dRadius:Double = 2000
    var filter = "Distance"

    var restaurants = [NLRestaurant]()
    let locationManager = CLLocationManager()
    weak var delegate: NLRestaurantViewModelDelegate?

    func searchRestaurantsWithAddress(address:String, radius:Double) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if error == nil {
                let placemark = placemarks?.first
                if let coords = placemark?.location?.coordinate {
                    RequestManager.sharedInstance.requestRestaurantsWithCoordinates(location: coords, radius: radius, completion: { (success, json) in
                        if let results = json?["results"] as? [[String:Any]] {
                            print(results)
                            self.parseRestaurants(data: results)
                            self.delegate?.restaurantsLoaded(searchedCoords: coords)
                        }
                    })
                }
            }
            else {
               self.delegate?.restaurantsLoaded(searchedCoords: nil)
            }
        }
    }
    
    func getlocation() {
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 9, *)  {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestLocation()

        }
        else {
            self.locationManager.requestLocation()
        }
    }
    
    func randomRestaurant() -> NLRestaurant {
       return self.restaurants.randomItem()
    }
    
    func parseRestaurants(data:[[String:Any]]) {
        self.restaurants.removeAll()
        for values in data {
            if let types = values["types"] as? [String] {
                if types.contains("food") || types.contains("restaurant") {
                    let restaurant = NLRestaurant(placeData: values as [String : AnyObject])
                    self.restaurants.append(restaurant)
                }
            }
        }
    }
}

extension NLRestaurantViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
         let location = locations.last
         if let coords = location?.coordinate {
            RequestManager.sharedInstance.requestRestaurantsWithCoordinates(location: coords, radius: dRadius, completion: { (success, json) in
                if let results = json?["results"] as? [[String:Any]] {
                    print(results)
                    self.parseRestaurants(data: results)
                    self.delegate?.restaurantsLoaded(searchedCoords: coords)
                }
            })
         }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.locationFailure()
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

