//
//  PlaceReviewViewController.swift
//  Places
//
//  Created by Edward Siu on 4/21/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftSpinner
import EasyToast

class PlaceReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var reviewSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var orderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var reviews: [Review] = []
    var sortedReviews: [Review] = []
    var yelpReviews: [YelpReview] = []
    var sortedYelpReviews: [YelpReview] = []
    let dateFormatter = DateFormatter()
    var place: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGoogleReviews()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        var count: Int!
        if reviewSegmentedControl.selectedSegmentIndex == 0 {
            count = self.reviews.count
        } else {
            count = self.yelpReviews.count
        }
        if count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Reviews"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewSegmentedControl.selectedSegmentIndex == 0 {
            return reviews.count
        } else {
            return yelpReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "reviewTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReviewTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlaceResultTableViewCell")
        }
        if reviewSegmentedControl.selectedSegmentIndex == 0 {
            var review: Review!
            if sortModeSegmentedControl.selectedSegmentIndex == 0 {
                review = reviews[indexPath.row]
            } else {
                review = sortedReviews[indexPath.row]
            }
            cell.authorLabel.text = review.author_name
            cell.ratingView.rating = review.rating
            let date = Date(timeIntervalSince1970: Double(review.time))
            cell.timeLabel.text = dateFormatter.string(from: date)
            let url = URL(string: review.profile_photo_url)
            cell.profilePhoto.kf.setImage(with: url)
            cell.reviewText.text = review.text
            cell.page = review.author_url
        } else {
            var review: YelpReview!
            if sortModeSegmentedControl.selectedSegmentIndex == 0 {
                review = yelpReviews[indexPath.row]
            } else {
                review = sortedYelpReviews[indexPath.row]
            }
            cell.authorLabel.text = review.user.name
            cell.ratingView.rating = review.rating
            cell.timeLabel.text = review.time_created
            let url = URL(string: review.user.image_url)
            cell.profilePhoto.kf.setImage(with: url) { (image, error, cachetype, url) in
                if let image = image {
                    cell.profilePhoto.image = image.roundImage()
                }
            }
            cell.reviewText.text = review.text
            cell.page = review.url
        }
        return cell
    }

    @IBAction func switchReviewsAction(_ sender: UISegmentedControl) {
        if reviewSegmentedControl.selectedSegmentIndex == 1 && yelpReviews.count == 0 {
            getYelpReviews()
        } else {
            if sortModeSegmentedControl.selectedSegmentIndex != 0 {
                self.sortReviews()
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func switchSortAction(_ sender: UISegmentedControl) {
        if sortModeSegmentedControl.selectedSegmentIndex != 0 {
            self.sortReviews()
        }
        self.tableView.reloadData()
    }
    
    @IBAction func switchOrderAction(_ sender: UISegmentedControl) {
        if sortModeSegmentedControl.selectedSegmentIndex != 0 {
            self.sortReviews()
        }
        self.tableView.reloadData()
    }
    
    private func sortReviews() {
        switch (reviewSegmentedControl.selectedSegmentIndex, sortModeSegmentedControl.selectedSegmentIndex) {
        case (0, 1):
            self.sortGoogleReviewByRating()
        case (0, 2):
            self.sortGoogleReviewByDate()
        case (1, 1):
            self.sortYelpReviewByRating()
        case (1, 2):
            self.sortYelpReviewByDate()
        default:
            return
        }
    }
    
    private func sortGoogleReviewByRating() {
        self.sortedReviews = self.sortedReviews.sorted {
            if self.orderSegmentedControl.selectedSegmentIndex == 0 {
                return $0.rating < $1.rating
            } else {
                return $1.rating < $0.rating
            }
        }
    }
    
    private func sortGoogleReviewByDate() {
        self.sortedReviews = self.sortedReviews.sorted {
            if self.orderSegmentedControl.selectedSegmentIndex == 0 {
                return $0.time < $1.time
            } else {
                return $1.time < $0.time
            }
        }
    }
    
    private func sortYelpReviewByRating() {
        self.sortedYelpReviews = self.sortedYelpReviews.sorted {
            if self.orderSegmentedControl.selectedSegmentIndex == 0 {
                return $0.rating < $1.rating
            } else {
                return $1.rating < $0.rating
            }
        }
    }
    
    private func sortYelpReviewByDate() {
        self.sortedYelpReviews = self.sortedYelpReviews.sorted {
            if self.orderSegmentedControl.selectedSegmentIndex == 0 {
                return $0.time_created < $1.time_created
            } else {
                return $1.time_created < $0.time_created
            }
        }
    }
    
    private func getGoogleReviews() {
        let tbvc = tabBarController as! PlaceDetailViewController
        reviews = tbvc.place?.reviews ?? []
        sortedReviews = reviews
        place = tbvc.place
    }
    
    private func getYelpReviews() {
        SwiftSpinner.show("Searching for reviews...")
        let addressComponents = place!.address_components
        let parameters: Parameters = [
            "name": place!.name,
            "address1": getAddressName(addressComponents: addressComponents!),
            "city": getCity(addressComponents: addressComponents!),
            "state": getState(addressComponents: addressComponents!),
            "country": getCountry(addressComponents: addressComponents!)
        ]
        Alamofire.request("https://places-ios-201920.appspot.com/api/yelp/reviews", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let data = response.data {
                guard let results = try? JSONDecoder().decode([YelpReview].self, from: data) else {
                    print("Failed to get yelp reviews")
                    SwiftSpinner.hide()
                    return
                }
                self.yelpReviews = results
                self.sortedYelpReviews = results
                self.tableView.reloadData()
                SwiftSpinner.hide()
            }
        }
    }
    
    private func getAddressName(addressComponents: [AddressComponent]) -> String {
        return "\(addressComponents[0].short_name) \(addressComponents[1].short_name)"
    }
    
    private func getCity(addressComponents: [AddressComponent]) -> String {
        for addr in addressComponents {
            if addr.types[0] == "locality" {
                return addr.short_name
            }
        }
        return ""
    }
    
    private func getState(addressComponents: [AddressComponent]) -> String {
        for addr in addressComponents {
            if addr.types[0] == "administrative_area_level_1" {
                return addr.short_name
            }
        }
        return ""
    }
    
    private func getCountry(addressComponents: [AddressComponent]) -> String {
        for addr in addressComponents {
            if addr.types[0] == "country" {
                return addr.short_name
            }
        }
        return ""
    }
}
