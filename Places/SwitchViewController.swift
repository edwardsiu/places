//
//  SwitchViewController.swift
//  Places
//
//  Created by Edward Siu on 4/20/18.
//  Copyright © 2018 asm. All rights reserved.
//

import UIKit

class SwitchViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var viewContainer: UIView!
    private lazy var searchFormViewController: SearchFormViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "SearchFormViewController") as! SearchFormViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var favoriteViewController: FavoriteViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        globalFavorites = loadFavorites()
        // Do any additional setup after loading the view.
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
    
    //MARK: Action
    @IBAction func switchViewAction(_ sender: UISegmentedControl) {
        updateView()
    }
    
    //MARK: Private
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        viewContainer.addSubview(viewController.view)
        viewController.view.frame = viewContainer.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    private func updateView() {
        if segmentControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: favoriteViewController)
            add(asChildViewController: searchFormViewController)
        } else {
            remove(asChildViewController: searchFormViewController)
            add(asChildViewController: favoriteViewController)
        }
    }
    
    private func loadFavorites() -> [PlaceStore] {
        //print("loading favorites")
        if let favorites = NSKeyedUnarchiver.unarchiveObject(withFile: PlaceStore.ArchiveURL.path) as? [PlaceStore] {
            return favorites
        } else {
            return []
        }
        
    }
    
}
