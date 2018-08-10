//
//  PlaceResult.swift
//  Places
//
//  Created by Edward Siu on 4/20/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import EasyToast
import os.log

class PlaceResultTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var favImageView: UIImageView!
    var place: Place?
    var isFavorite: Bool?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        favImageView.isUserInteractionEnabled = true
        favImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteTapped(sender:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFavoriteIcon() {
        if isFavorite ?? false {
            favImageView.image = UIImage(named: "favoriteFilled")
        } else {
            favImageView.image = UIImage(named: "favoriteEmpty")
        }
    }

    @objc func favoriteTapped(sender: UITapGestureRecognizer) {
        if isFavorite! {
            isFavorite = false
            favImageView.image = UIImage(named: "favoriteEmpty")
            self.superview!.showToast("\(place!.name) was removed from favorites", position: .bottom, popTime: 2, dismissOnTap: false)
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
            favImageView.image = UIImage(named: "favoriteFilled")
            self.superview!.showToast("\(place!.name) was added to favorites", position: .bottom, popTime: 2, dismissOnTap: false)
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
