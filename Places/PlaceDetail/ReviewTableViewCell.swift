//
//  ReviewTableViewCell.swift
//  Places
//
//  Created by Edward Siu on 4/24/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    var page: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeReview(sender:))))
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func seeReview(sender: UITapGestureRecognizer) {
        if let url = URL(string: self.page!) {
            UIApplication.shared.open(url, options: [:])
        }
    }

}

extension UIImage {
    func roundImage() -> UIImage? {
        let newImage = self.copy() as! UIImage
        let boundingDimension = min(self.size.width, self.size.height)
        let cornerRadius = boundingDimension/2
        let cgSize = CGSize(width: boundingDimension, height: boundingDimension)
        UIGraphicsBeginImageContextWithOptions(cgSize, false, 1.0)
        let bounds = CGRect(origin: .zero, size: cgSize)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        newImage.draw(in: bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
}
