//
//  PlaceMapViewController.swift
//  Places
//
//  Created by Edward Siu on 4/21/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import SwiftSpinner
import Alamofire

class PlaceMapViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    
    var place: Place?
    var startingPlace: GMSPlace?
    var polyLine: GMSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tbvc = tabBarController as! PlaceDetailViewController
        place = tbvc.place
        let camera = GMSCameraPosition.camera(withLatitude: (place!.geometry?.location.lat)!, longitude: (place!.geometry?.location.lng)!, zoom: 16)
        self.mapView.camera = camera
        let initialLoc = CLLocationCoordinate2DMake((place!.geometry?.location.lat)!, (place!.geometry?.location.lng)!)
        let marker = GMSMarker(position: initialLoc)
        marker.title = place!.name
        marker.map = mapView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.mapView.clear()
        self.fromTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func autoCompletePlace(_ sender: UITapGestureRecognizer) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func switchTravelMode(_ sender: UISegmentedControl) {
        if self.startingPlace != nil {
            self.drawDirections()
        }
    }
    
    private func updateStartingPlaceTextField() {
        fromTextField.text = startingPlace!.formattedAddress
    }
    
    private func drawDirections() {
        var mode: String!
        switch modeSegmentedControl.selectedSegmentIndex {
        case 0:
            mode = "driving"
        case 1:
            mode = "bicycling"
        case 2:
            mode = "transit"
        case 3:
            mode = "walking"
        default:
            mode = "driving"
        }
        SwiftSpinner.show("Getting directions...")
        let parameters: Parameters = [
            "originlat": self.startingPlace!.coordinate.latitude,
            "originlon": self.startingPlace!.coordinate.longitude,
            "destlat": self.place!.geometry!.location.lat,
            "destlon": self.place!.geometry!.location.lng,
            "mode": mode
        ]
        Alamofire.request("https://places-ios-201920.appspot.com/api/directions", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let data = response.data {
                guard let directions = try? JSONDecoder().decode(Directions.self, from: data) else {
                    print("Failed to decode directions results")
                    return
                }
                SwiftSpinner.hide()
                let path: GMSPath = GMSPath(fromEncodedPath: directions.routes[0].overview_polyline.points)!
                self.mapView.clear()
                self.polyLine = GMSPolyline(path: path)
                self.polyLine!.map = self.mapView
                self.polyLine!.spans = [GMSStyleSpan(color: .blue)]
                self.polyLine!.strokeWidth = 4.0
                let origin = self.startingPlace?.coordinate
                let destination = CLLocationCoordinate2D(latitude: (self.place?.geometry?.location.lat)!, longitude: (self.place?.geometry?.location.lng)!)
                let originMarker = GMSMarker(position: origin!)
                originMarker.title = self.startingPlace!.name
                originMarker.map = self.mapView
                let destinationMarker = GMSMarker(position: destination)
                destinationMarker.title = self.place!.name
                destinationMarker.map = self.mapView
                let bounds = GMSCoordinateBounds(coordinate: origin!, coordinate: destination)
                let camera = self.mapView.camera(for: bounds, insets: UIEdgeInsets())!
                self.mapView.camera = camera
            }
        }
        
    }
    
}

extension PlaceMapViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        startingPlace = place
        updateStartingPlaceTextField()
        dismiss(animated: true, completion: nil)
        drawDirections()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
