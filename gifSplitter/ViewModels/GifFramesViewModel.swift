//
//  GifFramesViewModel.swift
//  gifSplitter
//
//  Created by Austin Lam on 8/24/22.
//

import Foundation
import UIKit

class GifFramesViewModel {
    var gifData: Data?
    var gifFrames = [UIImage]()
    
    init(with gifData: Data?) {
        self.gifData = gifData
        
        guard let gifData = gifData, let imageSource = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("Cannot create image source with data!")
            return
        }
        
        let framesCount = CGImageSourceGetCount(imageSource)
        for index in 0 ..< framesCount {
            if let cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                let uiImageRef = UIImage(cgImage: cgImageRef)
                gifFrames.append(uiImageRef)
            }
        }
    }
}
