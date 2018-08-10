//
//  PlaceDetailViewController.swift
//  Places
//
//  Created by Edward Siu on 4/23/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import EasyToast
import os.log

class PlaceDetailViewController: UITabBarController {
    
    var place: Place?
    var isFavorite: Bool?
    var twitterBarButton: UIBarButtonItem!
    var favoriteBarButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getPlaceDetails()
        navigationItem.title = place!.name

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFavorite = false
        for fav in globalFavorites {
            if fav.place_id == place!.place_id {
                isFavorite = true
            }
        }
        setupBarButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private
    private func getPlaceDetails() {
        SwiftSpinner.show("Searching...")
        let parameters: Parameters = [
            "placeid": place!.place_id
        ]
        Alamofire.request("https://places-ios-201920.appspot.com/api/details", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let data = response.data {
                guard let detailResult = try? JSONDecoder().decode(DetailResult.self, from: data) else {
                    print("Failed to decode detail result")
                    return
                }
                self.place = detailResult.result
                //print(String(describing: self.place))
            }
            if let infoTabVC = self.viewControllers?[TabType.PlaceInfoViewController.rawValue] as? PlaceInfoViewController {
                infoTabVC.updateLabels()
                print("reached update label method in PlaceDetailViewController")
            } else {
                print("Couldn't get child tab view")
            }
            SwiftSpinner.hide()
        }
    }
    
    private func setupBarButtons() {
        let twitterIcon = UIImage(named: "forwardArrow")
        twitterBarButton = UIBarButtonItem(image: twitterIcon, style: .plain, target: self, action: #selector(PlaceDetailViewController.tapTweet(sender:)))
        var favoriteIcon: UIImage!
        if isFavorite! {
            favoriteIcon = UIImage(named: "favoriteFilled")
        } else {
            favoriteIcon = UIImage(named: "favoriteEmpty")
        }
        favoriteBarButton = UIBarButtonItem(image: favoriteIcon, style: .plain, target: self, action: #selector(PlaceDetailViewController.tapFavorite(sender:)))
        navigationItem.setRightBarButtonItems([favoriteBarButton, twitterBarButton], animated: true)
    }
    
    @objc private func tapTweet(sender: UIBarButtonItem) {
        let website = place!.website ?? ""
        var site: String!
        if website.isEmpty {
            site = place!.url
        } else {
            site = place!.website
        }
        let scheme = "https"
        let host = "twitter.com"
        let path = "/intent/tweet"
        let tweetText = "Check out \(place!.name) located at \(place!.formatted_address). Website: \(site!)"
        let tweetTags = "TravelAndEntertainmentSearch"
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = [
            URLQueryItem(name: "text", value: tweetText),
            URLQueryItem(name: "hashtags", value: tweetTags)
        ]
        if let url = urlComponents.url {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc private func tapFavorite(sender: UIBarButtonItem) {
        if isFavorite! {
            isFavorite = false
            let favoriteEmptyImage = UIImage(named: "favoriteEmpty")
            favoriteBarButton.image = favoriteEmptyImage
            self.view.showToast("\(place!.name) was removed from favorites", position: .bottom, popTime: 2, dismissOnTap: false)
            for (i, fav) in globalFavorites.enumerated() {
                if fav.place_id == place!.place_id {
                    globalFavorites.remove(at: i)
                    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(globalFavorites, toFile: PlaceStore.ArchiveURL.path)
                    if isSuccessfulSave {
                        os_log("Place successfully saved.", log: OSLog.default, type: .debug)
                    } else {
                        os_log("Failed to save place...", log: OSLog.default, type: .error)
                    }
                    return
                }
            }
        } else {
            isFavorite = true
            let favoriteFilledImage = UIImage(named: "favoriteFilled")
            favoriteBarButton.image = favoriteFilledImage
            self.view.showToast("\(place!.name) was added to favorites", position: .bottom, popTime: 2, dismissOnTap: false)
            let placeStore = PlaceStore(name: place!.name, address: place!.formatted_address, icon: place!.icon, id: place!.place_id)
            globalFavorites.append(placeStore)
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(globalFavorites, toFile: PlaceStore.ArchiveURL.path)
            if isSuccessfulSave {
                os_log("Place successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save place...", log: OSLog.default, type: .error)
            }
        }
    }

}
