//
//  ExpandViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/5/24.
//

import UIKit

class ExpandViewController: UIViewController {
    
    static let identifier = "ExpandViewController"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var TransparentImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    
    
    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    
    @IBOutlet private weak var editorView: UIView!
    
    @IBOutlet private weak var appCollectionView: UICollectionView!
    @IBOutlet private weak var aspectCollectionView: UICollectionView!
    @IBOutlet private weak var apiButton: UIButton!
    
    var pickedImage: UIImage!
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    var selectedAspectRatio: CGFloat!

    private var selectedAppIndex: Int = 0
    private var selectedAspectIndex: Int = 0
    
    private var selectedUniqueAspectIdentifier: String = "Standard Original" // used image to identify
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
        loadCollectionViews()
    }
    
    private func setupUI() {
        imageView.image = pickedImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
    }
    
    private func bindData() {
        DataManager.shared.prepareDatasource()
        selectedAspectRatio = (pickedImage.size.width/pickedImage.size.height)
    }
    
    private func loadCollectionViews() {
//        let appLayout = UICollectionViewFlowLayout()
//        appLayout.scrollDirection = .horizontal
//        appLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Enable self-sizing cells
////        appLayout.itemSize =  UICollectionViewFlowLayout.automaticSize
//        appLayout.sectionInset.left = 10
//        appLayout.sectionInset.right = 10
//        
//        appCollectionView.collectionViewLayout = appLayout
        
        appCollectionView.delegate = self
        appCollectionView.dataSource = self

        appCollectionView.register(UINib(nibName: "AppCell", bundle: nil), forCellWithReuseIdentifier: AppCell.identifier)
        
        
//        let aspectLayout = UICollectionViewFlowLayout()
//        aspectLayout.scrollDirection = .horizontal
//        aspectLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Enable self-sizing cells
////        aspectLayout.itemSize =  UICollectionViewFlowLayout.automaticSize
//        aspectLayout.sectionInset.left = 22
////        aspectLayout.sectionInset.right = 22
//    
//
//        aspectCollectionView.collectionViewLayout = aspectLayout
        
        aspectCollectionView.delegate = self
        aspectCollectionView.dataSource = self

        aspectCollectionView.register(UINib(nibName: "AspectCell", bundle: nil), forCellWithReuseIdentifier: AspectCell.identifier)
//
    }
    
    private func presentProgressViewController() {
        guard let navVC = storyboard?.instantiateViewController(identifier: "ProgressNAVController") as?  UINavigationController else { return }
        
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        
        if let VC = navVC.topViewController as? ProgessViewController {
            VC.navigationController?.navigationBar.isHidden = true
            VC.pickedImage = pickedImage
            VC.imageData = imageData
            
            VC.topRatio = topRatio
            VC.bottomRatio = bottomRatio
            VC.leftRatio = leftRatio
            VC.rightRatio = rightRatio
            
            VC.selectedAspectRatio = selectedAspectRatio
            
            VC.downloadCompletion = { picked, downloaded in
//                self.pushDownloadViewController(pickedImage: picked, downloadedImage: downloaded)
                self.pushDownloadViewControllerV2(pickedImage: picked, downloadedImage: downloaded)
            }
        }
        
        present(navVC, animated: false)
    }
    
    private func pushDownloadViewController(pickedImage: UIImage, downloadedImage: UIImage) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: DownloadViewController.identifier) as? DownloadViewController else { return }
        
        VC.pickedImage = pickedImage
        VC.downloadedImage = downloadedImage
        VC.imageData = imageData

        VC.topRatio = topRatio
        VC.bottomRatio = bottomRatio
        VC.leftRatio = leftRatio
        VC.rightRatio = rightRatio

        VC.selectedAspectRatio = selectedAspectRatio
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
    private func pushDownloadViewControllerV2(pickedImage: UIImage, downloadedImage: UIImage) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: DownloadViewControllerV2.identifier) as? DownloadViewControllerV2 else { return }
        
        VC.pickedImage = pickedImage
        VC.downloadedImage = downloadedImage
        VC.imageData = imageData

        VC.topRatio = topRatio
        VC.bottomRatio = bottomRatio
        VC.leftRatio = leftRatio
        VC.rightRatio = rightRatio

        VC.selectedAspectRatio = selectedAspectRatio
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
    private func presentADLimitViewController() {
        guard let navVC = storyboard?.instantiateViewController(identifier: "ADLimitNAVController") as?  UINavigationController else { return }
        
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.modalTransitionStyle = .crossDissolve
        
        if let VC = navVC.topViewController as? ADLimitViewController {
            VC.navigationController?.navigationBar.isHidden = true
        }
        
        present(navVC, animated: true)
    }
    
    private func addMaskToCanvas() {
        let maskPath = UIBezierPath(ovalIn: CGRect(x: 0, y: (canvasView.bounds.height - canvasView.bounds.width)/2 , width: canvasView.bounds.width, height: canvasView.bounds.width))
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = maskPath.cgPath
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.canvasView.layer.mask = maskLayer
        }
    }
    
    private func removeMaskFromCanvas() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.canvasView.layer.mask = nil
        }
    }
    
    private func calculateRatioParameters() {
        let containerWidth = imageContainerView.bounds.width
        let containerHeight = imageContainerView.bounds.height
        let imageViewWidth =  imageView.bounds.width
        let imageViewHeight =  imageView.bounds.height

        let topConstraint = (containerHeight - imageViewHeight) / 2
        let bottomConstraint = (containerHeight - imageViewHeight) / 2
        let leftConstraint = (containerWidth - imageViewWidth) / 2
        let rightConstraint = (containerWidth - imageViewWidth) / 2

        // Convert to percentages
        topRatio = (topConstraint / imageViewHeight)
        bottomRatio = (bottomConstraint / imageViewHeight)
        leftRatio = (leftConstraint / imageViewWidth)
        rightRatio = (rightConstraint / imageViewWidth)
        
        print("Top Percentage: \(String(describing: topRatio)) %")
        print("Bottom Percentage: \(String(describing: bottomRatio)) %")
        print("Left Percentage: \(String(describing: leftRatio)) %")
        print("Right Percentage: \(String(describing: rightRatio)) %")
    }
    
    private func convertRatio(ratio: String) -> CGFloat {
        // Handle the special case of "Original"
        if ratio.lowercased() == "original" {
            return (pickedImage.size.width/pickedImage.size.height)
        }
        
        // Split the string by the colon character
        let components = ratio.split(separator: ":")
        
        // Ensure there are exactly two components
        guard components.count == 2,
              let widthRatio = Float(components[0]),
              let heigthRatio = Float(components[1]) 
        else { return 1.0 }
        
        // Perform the division
        return CGFloat(widthRatio / heigthRatio)
    }
    
    @IBAction func apiButtonPressed(_ sender: Any) {
        if PurchaseManager.shared.isPremiumUser { // premium
            calculateRatioParameters()
            presentProgressViewController()
        } else { // free
            if ADManager.shared.isAdLimitReached {
                presentADLimitViewController()
            } else {
                calculateRatioParameters()
                presentProgressViewController()
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ExpandViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == appCollectionView {
            guard let appItems = DataManager.shared.getSupportedAppsRootDataCount() else { return 0 }
            return appItems
        } else {
            guard let aspectItems = DataManager.shared.getSupportedAppsData(of: selectedAppIndex) else { return 0 } // selected index
            return aspectItems.items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == appCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCell.identifier, for: indexPath) as? AppCell else { return UICollectionViewCell() }
            
            if let appData = DataManager.shared.getSupportedAppsData(of: indexPath.item) {
//                cell.setup(title: appData.title, isSelected: indexPath.item == selectedAppIndex)
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AspectCell.identifier, for: indexPath) as? AspectCell else { return UICollectionViewCell() }
                        
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                cell.setup(image: aspectData[indexPath.item].selectedImage, isSelected: indexPath.item == selectedAspectIndex && selectedUniqueAspectIdentifier.lowercased() == aspectData[selectedAspectIndex].selectedImage.lowercased())
            }
            return cell
        }
    }
    
}

extension ExpandViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == appCollectionView {
            selectedAppIndex = indexPath.item
            appCollectionView.reloadData()
            aspectCollectionView.reloadData()
        }
        
        else if collectionView == aspectCollectionView {
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                selectedAspectRatio = convertRatio(ratio: aspectData[indexPath.item].ratio)
                print("selectedAspectRatio ", selectedAspectRatio ?? -1.0)
                
                selectedUniqueAspectIdentifier = aspectData[indexPath.item].selectedImage
                
                aspectData[indexPath.item].text.lowercased() == "profile" ? addMaskToCanvas() : removeMaskFromCanvas()
            }
            
            selectedAspectIndex = indexPath.item
            aspectCollectionView.reloadData()
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio))
                self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.pickedImage.size.width/self.pickedImage.size.height))
                
//                self.view.layoutIfNeeded()
                self.canvasView.layoutIfNeeded()
            }
        }
                
    }
    
    

}

//extension ExpandViewController:  UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if collectionView == appCollectionView {
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        } else {
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == appCollectionView {
//            return CGSize(width: 100   , height: 20)
//        } else {
//            return CGSize(width: 100   , height: 80)
//            
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        if collectionView == appCollectionView {
//            return 0
//        } else {
//            return 0
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        if collectionView == appCollectionView {
//            return 0
//        } else {
//            return 30
//        }
//    }
//}
