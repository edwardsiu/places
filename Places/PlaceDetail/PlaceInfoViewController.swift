//
//  PlaceInfoViewController.swift
//  Places
//
//  Created by Edward Siu on 4/21/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import Cosmos

class PlaceInfoViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var websiteLink: UITextView!
    @IBOutlet weak var googleLink: UITextView!
    
    var place: Place?
    override func viewDidLoad() {
        super.viewDidLoad()
        //updateLabels()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels() {
        print("calling update labels")
        let tbvc = tabBarController as! PlaceDetailViewController
        place = tbvc.place
        let address = place?.formatted_address ?? ""
        addressLabel.text = address
        let phoneNumber = place?.international_phone_number ?? ""
        if phoneNumber.isEmpty {
            phoneLabel.text = "No phone number found"
        } else {
            phoneLabel.text = phoneNumber
        }
        let priceLevel = place?.price_level ?? 0
        if priceLevel == 0 {
            priceLabel.text = "No price level found"
        } else {
            priceLabel.text = String(repeating: "$", count: Int(priceLevel))
        }
        let rating = place?.rating ?? 0
        if rating == 0 {
            cosmosView.rating = 0
        } else {
            cosmosView.rating = rating
        }
        let website = place?.website ?? ""
        if website.isEmpty {
            websiteLink.text = "No website found"
        } else {
            websiteLink.text = website
        }
        let googlepage = place?.url ?? ""
        if googlepage.isEmpty {
            googleLink.text = "No Google page found"
        } else {
            googleLink.text = googlepage
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
