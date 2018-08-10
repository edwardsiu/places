//
//  SearchFormViewController.swift
//  Places
//
//  Created by Edward Siu on 4/20/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import GooglePlaces
import os.log
import McPicker
import SwiftSpinner
import EasyToast
import Alamofire

class SearchFormViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    //MARK: Properties
    @IBOutlet weak var keywordText: UITextField!
    @IBOutlet weak var categoryText: McTextField!
    @IBOutlet weak var distanceText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    let METERS_PER_MILE = 1609.34
    let locationManager = CLLocationManager()
    
    var categories: [String] = [
        "Default",
        "Airport",
        "Amusement Park",
        "Aquarium",
        "Art Gallery",
        "Bakery",
        "Bar",
        "Beauty Salon",
        "Bowling Alley",
        "Bus Station",
        "Cafe",
        "Campground",
        "Car Rental",
        "Casino",
        "Lodging",
        "Movie Theater",
        "Museum",
        "Night Club",
        "Park",
        "Parking",
        "Restaurant",
        "Shopping Mall",
        "Stadium",
        "Subway Station",
        "Taxi Stand",
        "Train Station",
        "Transit Station",
        "Travel Agency",
        "Zoo"
    ]
    
    var startingPlace: GMSPlace!
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
            locationManager.requestWhenInUseAuthorization()
        }
        keywordText.delegate = self
        distanceText.delegate = self
        locationText.delegate = self
        
        let mcInputView = McPicker(data: [categories])
        categoryText.inputViewMcPicker = mcInputView
        categoryText.doneHandler = { [weak categoryText] (selections) in
            categoryText?.text = selections[0]!
        }
        categoryText.selectionChangedHandler = { [weak categoryText] (selections, componentThatChanged) in
            categoryText?.text = selections[componentThatChanged]!
        }
        categoryText.textFieldWillBeginEditingHandler = { [weak categoryText] (selections) in
            if categoryText?.text == "" {
                // Selections always default to the first value per component
                categoryText?.text = selections[0]
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
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
    
    //MARK: Actions
    @IBAction func searchPlacesAction(_ sender: UIButton) {
        let keyword = keywordText.text ?? ""
        if keyword.isEmpty {
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            return
        }
        SwiftSpinner.show("Searching...")
        let text = locationText.text ?? ""
        if text.isEmpty {
            placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    let place = placeLikelihoodList.likelihoods.first?.place
                    if let place = place {
                        self.searchForPlaces(place: place)
                    }
                }
            })
        } else {
            searchForPlaces(place: startingPlace)
        }
    }
    
    @IBAction func clearForm(_ sender: UIButton) {
        keywordText.text = ""
        categoryText.text = ""
        distanceText.text = ""
        locationText.text = ""
    }
    
    @IBAction func autoCompletePlace(_ sender: UITapGestureRecognizer) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //MARK: Private
    
    private func updateStartingPlaceTextField() {
        guard let place = startingPlace else {
            os_log("startingPlace not set", log: OSLog.default, type: .error)
            return
        }
        locationText.text = place.formattedAddress
    }
    
    private func searchForPlaces(place: GMSPlace!) {
        var category = (categoryText.text ?? "").lowercased()
        if category.isEmpty {
            category = "default"
        }
        let distance = distanceText.text ?? ""
        var radius = 10 * METERS_PER_MILE
        if !distance.isEmpty {
            radius = Double(distance)! * METERS_PER_MILE
        }
        let parameters: Parameters = [
            "keyword": keywordText.text!,
            "lat": place.coordinate.latitude,
            "lon": place.coordinate.longitude,
            "radius": radius,
            "category": category
        ]
        Alamofire.request("https://places-ios-201920.appspot.com/api/search", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            SwiftSpinner.hide()
            if let data = response.data {
                guard let results = try? JSONDecoder().decode(SearchResults.self, from: data) else {
                    print("Failed to decode nearby search results")
                    return
                }
                let resultsViewController: ResultsViewController = {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    return viewController
                }()
                resultsViewController.results += [results]
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(resultsViewController, animated: true)
                }
                
            }
        }
    }
    
}

extension SearchFormViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        startingPlace = place
        updateStartingPlaceTextField()
        dismiss(animated: true, completion: nil)
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
