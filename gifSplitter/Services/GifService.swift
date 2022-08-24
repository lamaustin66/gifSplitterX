//
//  GifService.swift
//  gifSplitter
//
//  Created by Austin Lam on 8/24/22.
//

import Foundation
import Photos
import UIKit

class GifService {
    func fetchGifs(isAscending: Bool) -> ([UIImage], [Data]) {
        var gifThumbnails = [UIImage]()
        var gifData = [Data]()
        
        guard let gifCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: nil).firstObject else { return (gifThumbnails, gifData) }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: isAscending)]
        let fetchResultOfAssets = PHAsset.fetchAssets(in: gifCollection, options: fetchOptions)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        fetchResultOfAssets.enumerateObjects { asset, index, stop in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { imageData, dataUTI, orientation, info in
                guard dataUTI == UTType.gif.identifier,
                      let imageData = imageData,
                      let gifThumbnail = try? UIImage(gifData: imageData, levelOfIntegrity: .default) else { return }
                gifThumbnails.append(gifThumbnail)
                gifData.append(imageData)
            }
        }
        
        return (gifThumbnails, gifData)
    }
}
