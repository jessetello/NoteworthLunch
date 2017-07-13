//
//  RequestManager.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/7/17.
//  Copyright © 2017 jt. All rights reserved.
//

import Foundation
import CoreLocation

class RequestManager {
    
    static let sharedInstance = RequestManager()
    typealias RequestHandler = (_ success:Bool,_ json:[String:Any]?) -> Void

    func requestRestaurantsWithCoordinates(location:CLLocationCoordinate2D, radius:Double, completion:@escaping RequestHandler) {
        
        let path = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + "\(location.latitude)," + "\(location.longitude)" + "&radius=\(radius)&type=restaurant&key=\(Constants.mapsKey)"
        print(path)
        if let url = URL(string: path) {
            let request = URLRequest(url:url)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        if let jsonData = data {
                            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] {
                                    completion(true, json)
                            }
                            completion(false, nil)
                        }
                        completion(false, nil)
                    } catch {
                        completion(false, nil)
                    }
                }
                }.resume()
        }
    }
    
}
