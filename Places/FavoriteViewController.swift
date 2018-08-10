//
//  FavoriteViewController.swift
//  Places
//
//  Created by Edward Siu on 4/20/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import Kingfisher
import os.log

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    //var favorites: [Place] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "favoriteSegue":
            guard let placeDetailViewController = segue.destination as? PlaceDetailViewController else {
                fatalError("Unexpected destination")
            }
            guard let selectedPlaceCell = sender as? FavoriteTableViewCell else {
                fatalError("Unexpected sender")
            }
            guard let indexPath = tableView.indexPath(for: selectedPlaceCell) else {
                fatalError("The selected cell is not displayed on table")
            }
            let selectedPlace = globalFavorites[indexPath.row]
            placeDetailViewController.place = Place(name: selectedPlace.name, address: selectedPlace.formatted_address, icon: selectedPlace.icon, id: selectedPlace.place_id)
            placeDetailViewController.isFavorite = true
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if globalFavorites.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Favorites"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalFavorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoriteTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoriteTableViewCell else {
            fatalError("The dequeued cell is not an instance of FavoriteTableViewCell")
        }
        let placeFav = globalFavorites[indexPath.row]
        cell.nameLabel.text = placeFav.name
        cell.addressLabel.text = placeFav.formatted_address
        let url = URL(string: placeFav.icon)
        cell.categoryImage.kf.setImage(with: url)
        cell.place = Place(name: placeFav.name, address: placeFav.formatted_address, icon: placeFav.icon, id: placeFav.place_id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            globalFavorites.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            if globalFavorites.count == 0 {
                tableView.deleteSections([0], with: .fade)
            }
            tableView.endUpdates()
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(globalFavorites, toFile: PlaceStore.ArchiveURL.path)
            if isSuccessfulSave {
                os_log("Place successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save place...", log: OSLog.default, type: .error)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}
