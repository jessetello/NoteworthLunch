//
//  ViewController.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/7/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import GoogleMaps
import SVProgressHUD


class SearchViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapListButton: UIBarButtonItem!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    
    @IBOutlet weak var random: UIButton!
    
    let restaurantViewModel = NLRestaurantViewModel()
    var pickerData = ["0.5","1","1.5","2"]
    var picker : UIPickerView!
    var distance: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: "Loading...")
        self.restaurantViewModel.delegate = self
        self.restaurantViewModel.getlocation()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.distanceField.text = "0.5"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        self.distanceField.addTarget(self, action: #selector(distanceAction(_:)), for: .touchDown)
    }

    @IBAction func mapListFlip(_ sender: UIBarButtonItem) {
        if sender.title == "List" {
            UIView.transition(with: self.view, duration: 0.6, options: .transitionFlipFromRight, animations: {
                self.view.insertSubview(self.tableView, aboveSubview: self.mapView)
                self.random.isHidden = true
            }, completion: { (finished) in
                self.mapListButton.title = "Map"
            })
        }
        else {
            UIView.transition(with: self.view, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                self.view.insertSubview(self.mapView, aboveSubview: self.tableView)
                self.random.isHidden = false

            }, completion: { (finished) in
                self.tableView.reloadData()
                self.mapListButton.title = "List"
            })
        }
    }
    
    func distanceAction(_ sender: UITextField) {
        pickerSetupForTextfield(textField: sender)
        sender.becomeFirstResponder()
    }
    
    
    func pickerSetupForTextfield(textField:UITextField) {
        // UIPickerView
        picker = UIPickerView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        textField.inputView = self.picker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.red
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SearchViewController.doneClick(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(SearchViewController.cancelClick(sender:)))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    func doneClick(sender:UIBarButtonItem) {
           self.distanceField.text = distance
           self.distanceField.resignFirstResponder()
    }
    
    func cancelClick(sender:UIBarButtonItem) {
        self.distanceField.resignFirstResponder()
    }

    @IBAction func search(_ sender: UIBarButtonItem) {
        if let add = self.addressField.text, var rad = Double(self.distanceField.text!)  {
            switch rad {
            case 0.5:
                rad = 1609.34/2
                break
            case 1:
                rad = 1609.34
                break
            case 1.5:
                rad = 1609.34 * 1.5
                break
            case 2.0:
                rad = 1609.34 * 2
                break
            default:
                break
            }
            self.restaurantViewModel.searchRestaurantsWithAddress(address: add, radius: rad)
        }
    }
    
    func setUpMapWithCooordinates(coordinates:CLLocationCoordinate2D?) {
        DispatchQueue.main.async {
            self.mapView.clear()
            if let lat = coordinates?.latitude, let lon = coordinates?.longitude {
                self.mapView.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14.5)
                self.mapView.delegate = self
                self.mapView.isMyLocationEnabled = true
                self.mapView.animate(toLocation: CLLocationCoordinate2DMake(lat, lon))
            
            var bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: coordinates!, coordinate: coordinates!)
                
            for rest in self.restaurantViewModel.restaurants {
                let marker = GMSMarker()
                marker.appearAnimation = .pop

                if let coords = rest.location, let name = rest.name {
                    marker.title = name
                    marker.position = coords
                }
                marker.map = self.mapView
                bounds = bounds.includingCoordinate(marker.position)
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
            }
            }
        }
    }
    
    @IBAction func ratingsPriceToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.restaurantViewModel.restaurants = self.restaurantViewModel.restaurants.sorted(by: { (rest1, rest2) -> Bool in
                return rest1.rating > rest2.rating
            })
        }
        else {
            self.restaurantViewModel.restaurants = self.restaurantViewModel.restaurants.sorted(by: { (rest1, rest2) -> Bool in
                    return rest1.priceLevel < rest2.priceLevel
            })
        }
        self.tableView.reloadData()
    }
    
    @IBAction func randomAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.mapView.clear()
            let marker = GMSMarker()
            marker.appearAnimation = .pop

            if let coords = self.restaurantViewModel.randomRestaurant().location, let name = self.restaurantViewModel.randomRestaurant().name {
                marker.title = name
                marker.position = coords
            }
            marker.map = self.mapView
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurantViewModel.restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NLRestaurantCell
        cell?.name.text = self.restaurantViewModel.restaurants[indexPath.row].name
        cell?.address.text = self.restaurantViewModel.restaurants[indexPath.row].address
        cell?.rating.text = "Rating: \(self.restaurantViewModel.restaurants[indexPath.row].rating)"
        cell?.price.text = "Price Level: \(self.restaurantViewModel.restaurants[indexPath.row].priceLevel)"
        return cell!
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //show details
        DispatchQueue.main.async {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let nav = story.instantiateViewController(withIdentifier: "Details") as? UINavigationController
        let sc = nav?.viewControllers.first as? DetailsViewController
        sc?.restaurant = self.restaurantViewModel.restaurants[indexPath.row]
        sc?.restaurantViewModel = self.restaurantViewModel
        self.navigationController?.present(nav!, animated: true, completion: nil)
        }
    }
}

extension SearchViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        distance = self.pickerData[row]
    }
}

extension SearchViewController: UIPickerViewDataSource {
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
}

extension SearchViewController: GMSMapViewDelegate {
   
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let restaurant = self.restaurantViewModel.restaurants.filter{ $0.name == marker.title }.first
        if let r = restaurant {
            //show details
            DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let nav = story.instantiateViewController(withIdentifier: "Details") as? UINavigationController
            let sc = nav?.viewControllers.first as? DetailsViewController
            sc?.restaurant = r
            sc?.restaurantViewModel = self.restaurantViewModel

            self.navigationController?.present(nav!, animated: true, completion: nil)
            }
        }
    }
}

extension SearchViewController: NLRestaurantViewModelDelegate {
   
    func restaurantsLoaded(searchedCoords: CLLocationCoordinate2D?) {
        if searchedCoords != nil {
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            self.setUpMapWithCooordinates(coordinates: searchedCoords)
        }
        else {
            let alert = UIAlertController(title: "Invalid Location", message: "Please try another address/location", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationFailure() {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "Error", message: "Failed to get location", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
