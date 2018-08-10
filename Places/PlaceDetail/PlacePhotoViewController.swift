//
//  PlacePhotoViewController.swift
//  Places
//
//  Created by Edward Siu on 4/21/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacePhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    

    var place: Place?
    var placePhotos: [UIImage] = []
    var photoMetaData: [GMSPlacePhotoMetadata]?
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tbvc = tabBarController as! PlaceDetailViewController
        place = tbvc.place
        placePhotos = []
        loadPhotos(placeId: place!.place_id)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.placePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let image = placePhotos[indexPath.row]
        cell.displayImage(image: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.photoCollectionView.frame.width
        let image = photoMetaData![indexPath.row]
        let scaleFactor = width / image.maxSize.width
        return CGSize(width: width, height: scaleFactor * image.maxSize.height)
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
    private func loadPhotos(placeId: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.photoMetaData = photos!.results
                for photo in photos!.results {
                    self.loadImageForMetadata(photoMetadata: photo)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.placePhotos += [photo!]
                self.photoCollectionView.reloadData()
            }
        })
    }
}
