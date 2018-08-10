//
//  ResultsViewController.swift
//  Places
//
//  Created by Edward Siu on 4/22/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftSpinner
import Alamofire

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    //var data: Data?
    var results: [SearchResults] = []
    var currentPage = 0
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTable.dataSource = self
        updatePageButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resultsTable.reloadData()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "DetailSegue":
            guard let placeDetailViewController = segue.destination as? PlaceDetailViewController else {
                fatalError("Unexpected destination")
            }
            guard let selectedPlaceCell = sender as? PlaceResultTableViewCell else {
                fatalError("Unexpected sender")
            }
            guard let indexPath = resultsTable.indexPath(for: selectedPlaceCell) else {
                fatalError("The selected cell is not displayed on table")
            }
            let selectedPlace = results[currentPage].results[indexPath.row]
            placeDetailViewController.place = selectedPlace
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    
    //MARK: Table Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        print(results[currentPage].results.count)
        if results[currentPage].results.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Results"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = results[currentPage].results.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PlaceResultTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlaceResultTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlaceResultTableViewCell")
        }
        let placeResult = results[currentPage].results[indexPath.row]
        cell.nameLabel.text = placeResult.name
        cell.addressLabel.text = placeResult.formatted_address
        let url = URL(string: placeResult.icon)
        cell.categoryImageView.kf.setImage(with: url)
        cell.place = placeResult
        var isFavorite = false
        for fav in globalFavorites {
            if fav.place_id == placeResult.place_id {
                isFavorite = true
            }
        }
        cell.isFavorite = isFavorite
        cell.setFavoriteIcon()
        return cell
    }
    
    //MARK: Actions
    @IBAction func getPrevResults(_ sender: UIButton) {
        if (currentPage > 0) {
            currentPage -= 1
            updatePageButtonState()
            resultsTable.reloadData()
        }
    }
    
    @IBAction func getNextResults(_ sender: UIButton) {
        if (currentPage+1) < results.count {
            currentPage += 1
            updatePageButtonState()
            resultsTable.reloadData()
        } else {
            if hasNextToken() {
                SwiftSpinner.show("Loading next page...")
                getNextPage()
            }
        }
    }
    
    //MARK: Private
    private func updatePageButtonState() {
        if (currentPage+1) == results.count && !hasNextToken() {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        prevButton.isEnabled = currentPage > 0
    }
    
    private func hasNextToken() -> Bool {
        let hasNext = results[currentPage].token ?? ""
        return !hasNext.isEmpty
    }
    
    private func getNextPage() {
        guard let pagetoken = results[currentPage].token else {
            print("No page token found for current page")
            SwiftSpinner.hide()
            return
        }
        let parameters: Parameters = [
            "pagetoken": pagetoken
        ]
        Alamofire.request("https://places-ios-201920.appspot.com/api/search", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            SwiftSpinner.hide()
            if let data = response.data {
                guard let nextPage = try? JSONDecoder().decode(SearchResults.self, from: data) else {
                    print("Failed to decode nearby search results")
                    return
                }
                self.results += [nextPage]
                self.currentPage += 1
                self.updatePageButtonState()
                self.resultsTable.reloadData()
            }
        }
    }
}
