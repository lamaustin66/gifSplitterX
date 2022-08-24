//
// BrowseGifViewController.swift
//

import UIKit
import Photos

class BrowseGifViewController: UIViewController {
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var noGifsIndicatorLabel: UILabel!
    
    weak var coordinator: MainCoordinator?
    var gifViewModel = GifViewModel()
    var playbackSetting = PlaybackSetting()
    
    override func viewDidLoad() {
        setupCollectionView()
        setupRefreshControl()
        setupSettingsBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout() // Without this, layout will be broken upon rotation if on iPad
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Prevent scroll view did scroll from firing too early
        collectionView.delegate = self
        collectionView.dataSource = self

        let transitionPercentage = min(1, (max(0, collectionView.contentOffset.y + 2 * UIScreen.main.bounds.size.height - collectionView.contentSize.height) / UIScreen.main.bounds.size.height))
        creatorLabel.alpha = transitionPercentage
    }
    
    func setupCollectionView() {
        // In order to make large titles work, collection view must be on top in story board (background with regards to hierarchy)
        // Want to bring it to the front by increasing zPosition, everything else is 0 by default
        collectionView.layer.zPosition = 1
    }
    
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func setupSettingsBarButton() {
        settingsBarButton.target = self
        settingsBarButton.action = #selector(settingsBarButtonClicked(sender:))
    }
    
    func refetchGifs() {
        gifViewModel.fetchGifs(isAscending: playbackSetting.isAscending)
        noGifsIndicatorLabel.isHidden = gifViewModel.gifThumbnails.count > 0
    }
    
    @objc func handleRefreshControl() {
        refetchGifs()
        
        self.collectionView.refreshControl?.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Makes large title animate better with refresh control (Apple's bug)
            self.collectionView.reloadSections(IndexSet(integer: 0)) // Alternative to reloadData which blinks
        }
    }
    
    @objc func settingsBarButtonClicked(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsNC = storyboard.instantiateViewController(withIdentifier: "settingsNavigationController") as! UINavigationController
        
        settingsNC.modalPresentationStyle = .popover
        settingsNC.popoverPresentationController?.barButtonItem = sender
        settingsNC.popoverPresentationController?.delegate = self
        
        (settingsNC.viewControllers.first as! SettingsViewController).delegate = self
        (settingsNC.viewControllers.first as! SettingsViewController).playbackSetting = self.playbackSetting
        
        self.present(settingsNC, animated: true)
    }
    
    @objc private func applicationDidBecomeActive() {
        refetchGifs()
        collectionView.reloadSections(IndexSet(integer: 0)) // reloadData causes blink
    }
}

extension BrowseGifViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifViewModel.gifThumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifCell", for: indexPath) as! BrowseGifCollectionViewCell
        cell.imageView.setGifImage(gifViewModel.gifThumbnails[indexPath.item])
        
        return cell
    }
}

extension BrowseGifViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gifData = gifViewModel.gifData[indexPath.item]
        coordinator?.selectedGif(with: gifData)
    }
}

extension BrowseGifViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIApplication.shared.statusBarOrientation.isPortrait ? CGSize(width: collectionView.frame.size.width / 2, height: collectionView.frame.size.width / 2) : CGSize(width: collectionView.frame.size.width / 3, height: collectionView.frame.size.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: UIScreen.main.bounds.size.height, right: 0)
    }
}

extension BrowseGifViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let transitionPercentage = min(1, (max(0, scrollView.contentOffset.y + 2 * UIScreen.main.bounds.size.height - scrollView.contentSize.height) / UIScreen.main.bounds.size.height))
        creatorLabel.alpha = transitionPercentage
    }
}

extension BrowseGifViewController: UIPopoverPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let settingsNC = presentationController.presentedViewController as? UINavigationController,
              let settingsVC = settingsNC.viewControllers.first as? SettingsViewController else { return }

        updateSetting(with: settingsVC.playbackSetting)
    }
}

extension BrowseGifViewController: SettingsDelegate {
    func updateSetting(with playbackSetting: PlaybackSetting) {
        self.playbackSetting = playbackSetting
        
        refetchGifs()
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}
