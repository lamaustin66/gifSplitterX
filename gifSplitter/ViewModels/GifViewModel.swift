//
//  GifViewModel.swift
//  gifSplitter
//
//  Created by Austin Lam on 8/24/22.
//

import Foundation
import UIKit

class GifViewModel {
    let gifService = GifService()
    var gifData: [Data] = []
    var gifThumbnails: [UIImage] = []
    
    func fetchGifs(isAscending: Bool) {
        (gifThumbnails, gifData) = gifService.fetchGifs(isAscending: isAscending)
    }
}
