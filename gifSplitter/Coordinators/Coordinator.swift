//
//  Coordinator.swift
//  gifSplitter
//
//  Created by Austin Lam on 8/24/22.
//

import Foundation
import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    
    func start()
}
