//
//  DownloadViewControllerV2.swift
//  Image Picker
//
//  Created by BCL Device-18 on 6/6/24.
//

import UIKit
import Photos

class DownloadViewControllerV2: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    static let identifier = "DownloadViewControllerV2"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var TransparentImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!

    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var previousImageView: UIImageView!
    
//    @IBOutlet weak var previousImageViewLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var previousImageViewTrailingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var previousImageViewTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var previousImageViewBottomConstraint: NSLayoutConstraint!

    //    @IBOutlet weak var previousImageViewAspectRatioConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var previousImageViewWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet private weak var compareImage: UIImageView!
    
    private var adPopupView: AdPopupView = UIView.fromNib()
    private var adLimitView: AdLimitView = UIView.fromNib()
    
    @IBOutlet private weak var bgView: UIView!
    
    @IBOutlet private weak var downloadContainerView: UIView!
    
    private var collectionView: UICollectionView!

    private var downloadedImageArray: [URL?] = [] {
        didSet{
            print("downloadedImageArray.count   \(downloadedImageArray.count)")
        }
    }
    
    private var cellCount: Int! = 2
    
    private var cellState: (( _ state: DynamicCellState ) -> Void)? = nil
    
    var pickedImage: UIImage!
    var downloadedImage: UIImage! = UIImage(named: "Golden Statue_cartoon") {
        didSet {
            guard let imageUrl = writeTempData(downloadedImage, name: downloadedImageArray.count) else { return }
            print("imageURL ", imageUrl)
            downloadedImageArray.append(imageUrl)
            lastSavedAssetIdentifiers.append("")
            print("lastSavedAssetIdentifiers ", lastSavedAssetIdentifiers.count,"[ ", lastSavedAssetIdentifiers, " ]")
        }
    }
    
    var renderedImage: UIImage!
    
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    var relativeHeightFactor: CGFloat!
    var relativeWidthFactor: CGFloat!
    var relativeCenterXFactor: CGFloat!
    var relativeCenterYFactor: CGFloat!
    
//    var centerOffset: CGPoint!
    
    var selectedAspectRatio: CGFloat! = 1.0
    
    private var selectedIndex: Int = 0
    
    private var lastSavedAssetIdentifiers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        addGesture()
        loadCollectionView()
        configAdPopup()
        configAdLimitPopup()
        
        
        
//        previousImageView.image = pickedImage
//        previousImageView.isHidden = true
//        
//        let x = imageView.frame.origin.x + (imageView.frame.origin.x * leftRatio)
//        let y = imageView.frame.origin.y + (imageView.frame.origin.y * topRatio)
//        
//        let w = imageView.frame.width * (1.0 - (leftRatio + rightRatio))
//        let h = imageView.frame.height * (1.0 - (topRatio + bottomRatio))
//        previousImageView.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: w, height: h))
        
        
        
        
//        previousImageViewLeadingConstraint.constant = /*imageContainerView.bounds.minX +*/ (imageContainerView.frame.minX * leftRatio)
//        previousImageViewTrailingConstraint.constant = /*imageContainerView.bounds.maxX -*/ (imageContainerView.frame.maxX * rightRatio)
//        previousImageViewTopConstraint.constant = /*imageContainerView.bounds.minY +*/ (imageContainerView.frame.minY * topRatio)
//        previousImageViewBottomConstraint.constant = /*imageContainerView.bounds.maxY -*/ (imageContainerView.frame.maxY * bottomRatio)
//        
        
        
        
        
//        previousImageViewLeadingConstraint.constant = /*imageContainerView.bounds.minX +*/ (imageView.frame.minX * leftRatio)
//        previousImageViewTrailingConstraint.constant = /*imageContainerView.bounds.maxX -*/ (imageView.frame.maxX * rightRatio)
//        previousImageViewTopConstraint.constant = /*imageContainerView.bounds.minY +*/ (imageView.frame.minY * topRatio)
//        previousImageViewBottomConstraint.constant = /*imageContainerView.bounds.maxY -*/ (imageView.frame.maxY * bottomRatio)
        
        
        
//        previousImageViewLeadingConstraint = previousImageViewLeadingConstraint.changeMultiplier(multiplier: leftRatio <= 0.0 ? leftRatio : 1.0)
//        previousImageViewTrailingConstraint = previousImageViewTrailingConstraint.changeMultiplier(multiplier: rightRatio <= 0.0 ? rightRatio : 1.0)
//        previousImageViewTopConstraint = previousImageViewTopConstraint.changeMultiplier(multiplier: topRatio <= 0.0 ? topRatio : 1.0)
//        previousImageViewBottomConstraint = previousImageViewBottomConstraint.changeMultiplier(multiplier: bottomRatio <= 0.0 ? bottomRatio : 1.0)
        
        
        
//        previousImageViewWidthConstraint.constant = imageView.frame.size.width * relativeWidthFactor
        
//        previousImageViewAspectRatioConstraint = self.previousImageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
        

    }
    
    func initialData() {
        pickedImage = UIImage(named: "Golden Statue_cartoon")
        downloadedImage = UIImage(named: "Golden Statue_cartoon")
        
        topRatio = 0.2
        bottomRatio = 0.2
        leftRatio = 0.2
        rightRatio = 0.2
        
        
//        writeTempData(downloadedImage, name: 22)
//        var img = readTempData(withName: 1)
//        removeTempData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio))
            self.view.layoutIfNeeded()
            
            self.imageViewHorizontalConstraint.constant = 0
            self.imageViewVerticalConstraint.constant = 0
            
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.imageView.contentMode = .scaleAspectFit
        }

    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.image = downloadedImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        compareImage.isUserInteractionEnabled = true
        
        bgView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.06).cgColor
        bgView.layer.borderWidth = 1
        
        self.view.layoutIfNeeded()
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (selectedAspectRatio) )
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
        
//        imageViewHorizontalConstraint.constant = centerOffset.x
//        imageViewVerticalConstraint.constant = centerOffset.y
        
        tempWidth = self.imageView.frame.width
        tempCenterX = self.imageViewHorizontalConstraint.constant
        tempCenterY = self.imageViewVerticalConstraint.constant
        
        self.imageViewWidthConstraint.constant = self.imageContainerView.frame.size.width
        
        self.view.layoutIfNeeded()
    }
    
    private func addGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressImage(_:)))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0
        imageView.addGestureRecognizer(longPressGesture)
        
        let longPressGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(longPressImageV3(_:)))
        longPressGesture1.delegate = self
        longPressGesture1.minimumPressDuration = 0
        compareImage.addGestureRecognizer(longPressGesture1)
    }
    
    private func loadCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: downloadContainerView.bounds, collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "DownloadCellV2", bundle: nil), forCellWithReuseIdentifier: DownloadCellV2.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
//        collectionView.contentInset = calculateInset(cellCount: cellCount)
        collectionView.backgroundColor = UIColor(red: 0.09, green: 0.1, blue: 0.11, alpha: 1)
        
        downloadContainerView.addSubview(collectionView)
        
        collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: true, scrollPosition: .left)
    }
    
    private func configAdPopup() {
//        adPopupView.frame = view.bounds
        
//        adPopupView.frame = UIScreen.main.bounds
//        view.addSubview(adPopupView)
        
//        adPopupView.addToWindow()
        
        adPopupView.addToKeyWindow()
        
        adPopupView.closePressed = {
            print("closeButtonPressed")
            self.adPopupView.hide() {}
        }
        
        adPopupView.purchasePressed = {
            print("purchaseButtonPressed")
            self.adPopupView.hide() {
                self.pushPurchaseViewController()
            }
        }
        
        adPopupView.adPressed = {
            print("adButtonPressed")
            if ADManager.shared.isAdLimitReached {
                self.adLimitView.show() {}
            } else {
                self.adPopupView.hide {
                                        
                    self.imageView.contentMode = .scaleAspectFill
                    self.imageView.image = self.downloadedImage
                    
                    self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.pickedImage.size.width/self.pickedImage.size.height) )
                    self.view.layoutIfNeeded()
                    
                    
                    self.presentProgressViewController()
                }
            }
        }
    }
    
    private func configAdLimitPopup() {
//        adLimitView.frame = view.bounds
//        adLimitView.frame = UIScreen.main.bounds
        
//        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
////        if let window = UIApplication.shared.windows.first {
//            adLimitView.frame = window.bounds
//        }
//        
//        view.addSubview(adLimitView)
//        self.navigationController?.view.addSubview(adLimitView)
        
//        adLimitView.addToWindow()
        
        
        adLimitView.addToKeyWindow()
        
        adLimitView.closePressed = {
            print("closeButtonPressed")
            self.adLimitView.hide() {}
        }
        
        adLimitView.purchasePressed = {
            print("purchaseButtonPressed")
            self.adLimitView.hide() {
                self.pushPurchaseViewController()
            }
        }
    }
    
    private func calculateInset(cellCount: Int) -> UIEdgeInsets {
        let cellWidth = 76 * cellCount
        let itemInterSpacing = 12 * (cellCount - 1)
        let allCellWidth = cellWidth + itemInterSpacing  // section inset 44
        let emptySpace = SCREEN_WIDTH - CGFloat(allCellWidth)
//        let emptySpace = self.downloadContainerView.frame.width - CGFloat(allCellWidth)
        let sideInset: CGFloat = emptySpace / 2
        
        return UIEdgeInsets(top: 20, left: max(sideInset, 22), bottom: 20, right: max(sideInset, 22))
    }
    
    private func checkSizes() {
        print("Top Percentage: \(String(describing: topRatio)) %")
        print("Bottom Percentage: \(String(describing: bottomRatio)) %")
        print("Left Percentage: \(String(describing: leftRatio)) %")
        print("Right Percentage: \(String(describing: rightRatio)) %")
        
        print("++pickedImage.size.width ", pickedImage.size.width)
        print("++pickedImage.size.height ", pickedImage.size.height)
        
        print("++pickedImage scale .width ", (pickedImage.size.width + (pickedImage.size.width * (leftRatio + rightRatio))) )
        print("++pickedImage scale .height ", (pickedImage.size.height + (pickedImage.size.height * (topRatio + bottomRatio))) )
        
        print("++downloadedImage.size.width ", downloadedImage.size.width)
        print("++downloadedImage.size.height ", downloadedImage.size.height)
        
        let widthScale = (pickedImage.size.width + (pickedImage.size.width * (leftRatio + rightRatio)))/downloadedImage.size.width
        let heightScale = (pickedImage.size.height + (pickedImage.size.height * (topRatio + bottomRatio)))/downloadedImage.size.height
        
        print("widthScale ", widthScale, " heightScale ", heightScale)
        
        let expectedWidth = (pickedImage.size.width + (pickedImage.size.width * (leftRatio + rightRatio)))
        let expectedHeight = (pickedImage.size.height + (pickedImage.size.height * (topRatio + bottomRatio)))
        
        if let renderedImage = downloadedImage.upscaleImage(width: expectedWidth, height: expectedHeight) {
            
            print("++renderedImage.size.width ", renderedImage.size.width)
            print("++renderedImage.size.height ", renderedImage.size.height)
            
            saveImageToPhotoLibrary(renderedImage)
        }
    }
    
    private func renderImage() {
        let expectedWidth = (pickedImage.size.width + (pickedImage.size.width * (leftRatio + rightRatio)))
        let expectedHeight = (pickedImage.size.height + (pickedImage.size.height * (topRatio + bottomRatio)))
        
        if let renderedImage = downloadedImage.upscaleImage(width: expectedWidth, height: expectedHeight) {
            
            print("++pickedImage.size.width ", pickedImage.size.width)
            print("++pickedImage.size.height ", pickedImage.size.height)
            print("++renderedImage.size.width ", renderedImage.size.width)
            print("++renderedImage.size.height ", renderedImage.size.height)
            print("++downloadedImage.size.width ", downloadedImage.size.width)
            print("++downloadedImage.size.height ", downloadedImage.size.height)
            
            self.renderedImage = renderedImage
        }
    }
    
    private func renderImageV2(image: UIImage) -> UIImage? {
        let expectedWidth = (pickedImage.size.width + (pickedImage.size.width * (leftRatio + rightRatio)))
        let expectedHeight = (pickedImage.size.height + (pickedImage.size.height * (topRatio + bottomRatio)))
        
        if let renderedImage = image.upscaleImage(width: expectedWidth, height: expectedHeight) {
            
            print("++pickedImage.size.width ", pickedImage.size.width)
            print("++pickedImage.size.height ", pickedImage.size.height)
            print("++renderedImage.size.width ", renderedImage.size.width)
            print("++renderedImage.size.height ", renderedImage.size.height)
            print("++downloadedImage.size.width ", downloadedImage.size.width)
            print("++downloadedImage.size.height ", downloadedImage.size.height)
            
            return renderedImage
        } else {
            return nil
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Image saved to photo library")
    }
           
    private func saveUniqueImageToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                print("Photo library access not authorized")
                return
            }
            else if status == .authorized {
                print("Photo library access authorized")
                if (PHAsset.fetchAssets(withLocalIdentifiers: [self.lastSavedAssetIdentifiers[self.selectedIndex]], options: nil).count > 0) {
                    print("Image already exists in the photo library")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Already Saved!", message: "Photo already saved")
                    }
                    return
                }
                else {
                    //save
                    PHPhotoLibrary.shared().performChanges {
                        let creationRequest = PHAssetCreationRequest.creationRequestForAsset(from: image)
                        let lastSavedAssetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier ?? ""
                        self.lastSavedAssetIdentifiers[self.selectedIndex] = lastSavedAssetIdentifier
                    } completionHandler: { success, error in
                        if success {
                            print("Successfully saved image to photo library")
                            DispatchQueue.main.async {
                                self.showAlert(title: "Saved!", message: "Successfully saved your creation to camera roll")
                            }
                        } else if let error = error {
                            print("Error saving image: \(error.localizedDescription)")
                            self.saveImageToPhotoLibrary(image)
                        }
                    }
                }
            }
        }
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
                self.downloadedImage = downloaded
                self.imageView.image = self.downloadedImage
                self.cellCount += 1
                self.selectedIndex = self.downloadedImageArray.count - 1
//                self.collectionView.contentInset = self.calculateInset(cellCount: self.cellCount)
                self.collectionView.insertItems(at: [IndexPath(item: self.selectedIndex, section: 0)])
                self.collectionView.reloadSections([0])
                self.collectionView.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: true, scrollPosition: .left)
            }
        }
    
        present(navVC, animated: true)
    }
    
    private func pushEditViewController() {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditViewController.identifier) as? EditViewController else { return }
        
//        VC.pickedImage = pickedImage
//        VC.downloadedImage = downloadedImage
//        VC.imageData = imageData
//
//        VC.topRatio = topRatio
//        VC.bottomRatio = bottomRatio
//        VC.leftRatio = leftRatio
//        VC.rightRatio = rightRatio
//
//        VC.selectedAspectRatio = selectedAspectRatio
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    private func pushPurchaseViewController() { // with present animation
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PurchaseViewController.identifier) as? PurchaseViewController else { return }
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .coverVertical
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .moveIn
        transition.subtype = .fromTop
        
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(VC, animated: false)
        
        
        VC.closeCompletion = {
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
            transition.type = .reveal
            transition.subtype = .fromBottom
            
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.popViewController(animated: false)
            
            if PurchaseManager.shared.isPremiumUser {
                self.adPopupView.hide(delay: 0.4) {}
            } else {
                self.adLimitView.show(delay: 0.4) {}
            }
        }
    }
    
    private func presentExpandViewControllerV2(pickedImage: UIImage, imageData: Data) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ExpandViewControllerV2.identifier) as? ExpandViewControllerV2 else { return }

//        VC.modalPresentationStyle = .fullScreen
//        VC.modalTransitionStyle = .crossDissolve
        VC.pickedImage = pickedImage
        VC.imageData = imageData
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    private func uploadImage(completion: @escaping ( _ downloadedImage: UIImage? ) -> Void) {
        print("uploadImage API CALLED")
//        isAPICalled = true
        completion(nil)
        APIManager.shared.uploadImage(imageData: imageData, leftPercentage: leftRatio, rightPercentage: rightRatio, topPercentage: topRatio, bottomPercentage: bottomRatio, keepOriginalSize: keepOriginalSize){ response in
            switch response {
            case .success(let data):
                print("download successful.")
                if let image = UIImage(data: data) {
                    
                    self.downloadedImage = image
//                    self.isDownloaded = true
                    completion(self.downloadedImage)
                    
                } else {
                    print("Failed to convert data to image")
                    self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    
//    private func regenerateImageV2() {
//        if PurchaseManager.shared.isPremiumUser {
//            lastSavedAssetIdentifier = ""
//            
//            uploadImage { image in
//                
//                if let image {
//                    // download finished
//                    self.downloadedImage = image
//                    self.imageView.image = image
//                    self.cellState?(.image)
//                }
//                else {
//                    // download strted
////                    another completion for cell change
//                    self.cellState?(.indicator)
//                    
//                }
//            }
//             
//        } else {
//            if ADManager.shared.isAdLimitReached {
//                presentADLimitViewController()
//            } else {
//                lastSavedAssetIdentifier = ""
//                
//                imageView.contentMode = .scaleAspectFill
//                imageView.image = downloadedImage
//                
//                self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
//                self.view.layoutIfNeeded()
//                
////                presentProgressViewController()
//            }
//        }
//    }
    
    
    private func regenerateImageV3() {
        if PurchaseManager.shared.isPremiumUser {
            
            imageView.contentMode = .scaleAspectFill
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
            self.view.layoutIfNeeded()
            
            presentProgressViewController()
        } else {
            adPopupView.show() {}
        }
    }
    
//    private func regenerateImage() {
//        if PurchaseManager.shared.isPremiumUser {
//            
//            imageView.contentMode = .scaleAspectFill
//            imageView.image = downloadedImage
//            
//            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
//            self.view.layoutIfNeeded()
//            
//            presentProgressViewController()
//            
//        } else {
//            if ADManager.shared.isAdLimitReached {
//                presentADLimitViewController()
//            } else {
//                
//                imageView.contentMode = .scaleAspectFill
//                imageView.image = downloadedImage
//                
//                self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
//                self.view.layoutIfNeeded()
//                
//                presentProgressViewController()
//            }
//        }
//    }
    
    @objc private func longPressImage(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .began:
            
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
            
            
//            self.imageViewHorizontalConstraint.constant = self.centerOffset.x
//            self.imageViewVerticalConstraint.constant = self.centerOffset.y
//            print("centerOffset x", self.centerOffset.x, " self.centerOffset y ", self.centerOffset.y)
            print("selectedAspectRatio ", self.selectedAspectRatio)
            self.view.layoutIfNeeded()

            UIView.transition(with: self.imageView, duration: 2.6, options: [.transitionCrossDissolve, .curveEaseInOut],  animations: {
                self.imageView.image = self.pickedImage
                
            })
            
            case .ended:
            
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio))
            
            self.imageViewHorizontalConstraint.constant = 0
            self.imageViewVerticalConstraint.constant = 0
            self.view.layoutIfNeeded()

            UIView.transition(with: self.imageView, duration: 0.6, options: [.transitionCrossDissolve, .curveEaseInOut],  animations: {
                self.imageView.image = self.downloadedImage
                
            })
            
            default: break
        }
    }
    
    var tempWidth: CGFloat!
    var tempCenterX: CGFloat!
    var tempCenterY: CGFloat!
    
    
    
    @objc private func longPressImageV2(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
            case .began:
                        
//            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.pickedImage.size.width/self.pickedImage.size.height) )
//            self.view.layoutIfNeeded()
            
//            self.imageViewHorizontalConstraint.constant = self.centerOffset.x
//            self.imageViewVerticalConstraint.constant = self.centerOffset.y

            UIView.transition(with: self.imageView, duration: 2.6, options: [.transitionCrossDissolve, .curveEaseInOut],  animations: {
                
                self.imageViewWidthConstraint.constant = self.tempWidth * self.relativeWidthFactor
                self.view.layoutIfNeeded()
                
//                self.imageViewHorizontalConstraint.constant = self.centerOffset.x * self.relativeCenterXFactor
//                self.imageViewVerticalConstraint.constant = self.centerOffset.y * self.relativeCenterYFactor
                
//                self.imageViewHorizontalConstraint.constant =
//                self.imageViewVerticalConstraint.constant =
                
                self.view.layoutIfNeeded()
    
                self.imageView.image = self.pickedImage
            })
            
            case .ended:
            
            UIView.transition(with: self.imageView, duration: 2.6, options: [.transitionCrossDissolve, .curveEaseInOut],  animations: {
                
                self.imageViewWidthConstraint.constant = self.tempWidth
                self.view.layoutIfNeeded()
                
                self.imageViewHorizontalConstraint.constant = 0 // self.tempCenterX
                self.imageViewVerticalConstraint.constant = 0 // self.tempCenterY
                
//                self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio) )
                
                self.view.layoutIfNeeded()
                
                guard let url = self.downloadedImageArray[self.selectedIndex], let img = readTempData(fileURL: url) else { return }
                self.imageView.image = img
            })
            
            default: break
        }
    }
    
    @objc private func longPressImageV3(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .began:
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
                    self.imageView.isHidden = true
                } completion: { _ in
                    self.previousImageView.isHidden = false
                }
                
            case .ended:
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
                    self.previousImageView.isHidden = true
                } completion: { _ in
                    self.imageView.isHidden = false
                }
                
            default: break
        }

    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func galleryButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let url = self.downloadedImageArray[selectedIndex], let img = readTempData(fileURL: url), let renderImg = renderImageV2(image: img) else { return }
        self.renderedImage = renderImg
        saveUniqueImageToPhotos(image: renderedImage)
    }
    
    @IBAction func editorButtonPressed(_ sender: Any) {
        pushEditViewController()
    }
}


extension DownloadViewControllerV2: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadCellV2.identifier, for: indexPath) as? DownloadCellV2 else { return UICollectionViewCell() }
//        if indexPath.item < cellCount { // before the last cell
        if indexPath.item < downloadedImageArray.count { // before the last cell
        
            
            if let url = self.downloadedImageArray[indexPath.item], let img = readTempData(fileURL: url) {
                cell.setup(image:  img, state: .image)
            }
            
            self.cellState = { state in
                if let url = self.downloadedImageArray[indexPath.item], let img = readTempData(fileURL: url) {
                    cell.setup(image:  img, state: state)
                }
            }
            
        } else if indexPath.item == downloadedImageArray.count { // at the last cell
            cell.setup(image: UIImage(), state: .regen)
        }
        
        return cell
    }
    
    
}


extension DownloadViewControllerV2: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped: Section \(indexPath.section) item \(indexPath.item)")
        //need to check which cell is tapped
        // last cell views popup // free
        // last cell calls api // paid
        
        if indexPath.item != downloadedImageArray.count {
            // if not last cell tapped
            selectedIndex = indexPath.item
            if let url = self.downloadedImageArray[indexPath.item], let img = readTempData(fileURL: url) {
                self.imageView.image = img
            }
            
            print("lastSavedAssetIdentifiers ", lastSavedAssetIdentifiers.count, "[ ", lastSavedAssetIdentifiers, " ]")
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == downloadedImageArray.count {
            // if last cell tapped
            regenerateImageV3()
            return false
        } else {
            return true
        }
    }
}


extension DownloadViewControllerV2: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickedImage = pickedImage
            print("pickedImage Width: \(self.pickedImage.size.width), pickedImage Height: \(self.pickedImage.size.height)")
            
            guard let fixedOrientationImage = pickedImage.fixedOrientation(), let imageData = fixedOrientationImage.jpegData(compressionQuality: 1.0) else {
                print("Failed to convert image to data")
                return
            }

            presentExpandViewControllerV2(pickedImage: pickedImage, imageData: imageData)
        }
        dismiss(animated: true, completion: nil)
        
        //  only the first and last in navstack
        guard let navigationController = self.navigationController else { return }
        let navigationArray = navigationController.viewControllers
        self.navigationController?.viewControllers = [navigationArray.first!, navigationArray.last!]
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension DownloadViewControllerV2: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.calculateInset(cellCount: cellCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 76, height: 76)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
}
