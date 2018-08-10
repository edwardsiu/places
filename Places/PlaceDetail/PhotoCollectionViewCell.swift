//
//  PhotoCollectionViewCell.swift
//  Places
//
//  Created by Edward Siu on 4/24/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var placeImage: UIImageView!
    
    func displayImage(image: UIImage) {
        placeImage.image = image
    }
}
