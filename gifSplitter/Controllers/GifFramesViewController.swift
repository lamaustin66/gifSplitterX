//
// GifFramesViewController.swift
//

import UIKit

class GifFramesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var savedIndicator: UILabel!
    
    var gifData: Data?
    var gifFrames = [UIImage]()
    var prevItem = 0
    
    // Rotating from portrait to landscape changes offset (Apple's bug)
    var mostRecentContentoffsetX = CGFloat.zero
    var verticalIndicatorLineForCurrentFrame: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupScrollView()
        setupVerticalIndicator()
        setupSaveFramesBarButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mostRecentContentoffsetX = collectionView.contentOffset.x
        collectionView.collectionViewLayout.invalidateLayout() // Increase the left and right section inset upon rotation
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentOffset.x = mostRecentContentoffsetX
        verticalIndicatorLineForCurrentFrame.path = UIBezierPath(rect: CGRect(x: view.bounds.width / 2, y: 0, width: 1, height: collectionView.frame.height)).cgPath
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
        gifImageView.image = gifFrames[0]
    }
    
    func setupScrollView() {
        scrollView.delegate = self
    }
    
    func setupVerticalIndicator() {
        verticalIndicatorLineForCurrentFrame = CAShapeLayer()
        verticalIndicatorLineForCurrentFrame.fillColor = UIColor.white.cgColor
        clearView.layer.addSublayer(verticalIndicatorLineForCurrentFrame)
    }
    
    func setupSaveFramesBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Frame", style: .plain, target: self, action: #selector(saveFrameTapped))
    }
    
    @objc func saveFrameTapped() {
        // Break the image down into png. This solves 2 things: image being saved as a gif, and image being compressed
        guard let pngData = gifImageView.image?.pngData(), let pngImage = UIImage(data: pngData) else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            savedIndicator.alpha = 1
            UIView.animate(withDuration: 1, animations: {
                self.savedIndicator.alpha = 0
            })
        }
    }
}


extension GifFramesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifFrames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifFrameCell", for: indexPath) as! GifFrameCollectionViewCell
        cell.imageView.image = gifFrames[indexPath.item]
        return cell
    }
}

extension GifFramesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: collectionView.bounds.width / 2 - collectionView.bounds.height / 2, bottom: 0, right: collectionView.bounds.width / 2 - collectionView.bounds.height / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension GifFramesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cv = scrollView as? UICollectionView,
              let item = cv.indexPathForItem(at: CGPoint(x: cv.contentOffset.x + cv.bounds.width / 2, y: 0))?.item,
              item != prevItem else {
            return
        }
        
        prevItem = item
        UISelectionFeedbackGenerator().selectionChanged()
        
        gifImageView.image = gifFrames[item]
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
