//
//  MainCoordinator.swift
//  gifSplitter
//
//  Created by Austin Lam on 8/24/22.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // Start coordinator with a root view controller
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseGifViewController") as! BrowseGifViewController
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func selectedGif(with data: Data) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GifFramesViewController") as! GifFramesViewController
        vc.coordinator = self
        vc.gifFramesViewModel = GifFramesViewModel(with: data)
        navigationController.pushViewController(vc, animated: true)
    }
}
