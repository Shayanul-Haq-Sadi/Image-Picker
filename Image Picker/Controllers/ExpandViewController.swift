//
//  ExpandViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/5/24.
//

import UIKit

class ExpandViewController: UIViewController {
    
    static let identifier = "ExpandViewController"
    
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var TransparentImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var editorView: UIView!
    
    @IBOutlet weak var appCollectionView: UICollectionView!
    @IBOutlet weak var aspectCollectionView: UICollectionView!
    @IBOutlet weak var apiButton: UIButton!
    
    var pickedImage: UIImage!
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    private var selectedAppIndex: Int = 0
    private var selectedAspectIndex: Int = 0
    var selectedAspectRatio: CGFloat = 1.0
    
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
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ProgessViewController.identifier) as? ProgessViewController else { return }
     
        VC.pickedImage = pickedImage
        VC.imageData = imageData
        
        VC.topRatio = topRatio
        VC.bottomRatio = bottomRatio
        VC.leftRatio = leftRatio
        VC.rightRatio = rightRatio
        
        VC.selectedAspectRatio = selectedAspectRatio
        
        VC.downloadCompletion = { picked, downloaded in
            self.pushEditViewController(pickedImage: picked, downloadedImage: downloaded)
        }
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        present(VC, animated: true)
    }
    
    private func pushEditViewController(pickedImage: UIImage, downloadedImage: UIImage) {
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
        
        self.navigationController?.pushViewController(VC, animated: true)
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
        
        print("Top Percentage: \(topRatio) %")
        print("Bottom Percentage: \(bottomRatio) %")
        print("Left Percentage: \(leftRatio) %")
        print("Right Percentage: \(rightRatio) %")
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
        calculateRatioParameters()
        presentProgressViewController()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ExpandViewController: UICollectionViewDataSource {
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
                cell.setup(title: appData.title, isSelected: indexPath.item == selectedAppIndex)
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AspectCell.identifier, for: indexPath) as? AspectCell else { return UICollectionViewCell() }
                        
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                cell.setup(image: aspectData[indexPath.item].image, isSelected: indexPath.item == selectedAspectIndex && selectedUniqueAspectIdentifier.lowercased() == aspectData[selectedAspectIndex].image.lowercased())
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
                print("selectedAspectRatio ", selectedAspectRatio)
                
                selectedUniqueAspectIdentifier = aspectData[indexPath.item].image
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
