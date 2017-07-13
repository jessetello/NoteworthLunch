//
//  DetailsViewController.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/7/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import GooglePlaces

class DetailsViewController: UIViewController {
   
    var restaurant: NLRestaurant?
    var restaurantViewModel: NLRestaurantViewModel?

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    init(restaurant:NLRestaurant, model:NLRestaurantViewModel) {
        self.restaurant = restaurant
        self.restaurantViewModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.text = self.restaurant?.name
        self.price.text = "Price Level: \(self.restaurant?.priceLevel ?? 0)"
        self.rating.text = "Rating: \(self.restaurant?.rating ?? 0) out of 5"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .up
        let dist = CLLocation.distance(from: (self.restaurantViewModel?.locationManager.location?.coordinate)!, to: (self.restaurant?.location!)!) * 0.000621371
        let distForm = formatter.string(from: NSNumber(value: dist))
        if let d = distForm {
            self.distance.text = "\(d) mi. away"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gc = segue.destination as? GraphsViewController
        gc?.restaurantViewModel = self.restaurantViewModel
        gc?.restaurant = self.restaurant
        if segue.identifier == "PriceRating" {
            gc?.graphType = GraphType.price
        } else if segue.identifier == "HoursOpen" {
            gc?.graphType = GraphType.hours
        } else if segue.identifier == "OpenClosed" {
            gc?.graphType = GraphType.openClosed
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CLLocation {
    // In meters
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
