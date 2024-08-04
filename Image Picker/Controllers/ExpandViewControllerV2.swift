//
//  ExpandViewControllerV2.swift
//  Image Picker
//
//  Created by BCL Device-18 on 3/7/24.
//

import UIKit
import AVFoundation
class ExpandViewControllerV2: UIViewController {
    
    static let identifier = "ExpandViewControllerV2"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var TransparentImageView: UIImageView!
    
    
    @IBOutlet private weak var centerXAxisView: UIView!
    @IBOutlet private weak var centerYAxisView: UIView!
    
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewVerticalConstraint: NSLayoutConstraint!

    @IBOutlet private weak var imageCropOverlayView: CropOverlayView!
    
    
    @IBOutlet private weak var separatorView: UIView!
    
    
    @IBOutlet private weak var editorView: UIView!
    
    @IBOutlet private weak var appContainerView: UIView!
    @IBOutlet private weak var aspectContainerView: UIView!
    
    private var appCollectionView: UICollectionView!
    private var aspectCollectionView: UICollectionView!
    
    @IBOutlet private weak var bgView: UIView!
    
    
    @IBOutlet private weak var navContainerView: UIView!
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var apiButton: UIButton!
    
    private var adPopupView: AdPopupView = UIView.fromNib()
    private var adLimitView: AdLimitView = UIView.fromNib()
    
    var pickedImage: UIImage!
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
    
    var selectedAspectRatio: CGFloat!

    private var selectedAppIndex: Int = 0
    private var selectedAspectIndex: Int = 0
    
    private var selectedUniqueAspectIdentifier: String!
    
    private var generator : UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
        addGestures()
        loadCollectionViews()
        configAdPopup()
        configAdLimitPopup()
        
        if let edgeDistances = imageView.edgeDistancesToSuperview() {
            print("top ", edgeDistances.top, " bottom ", edgeDistances.bottom, " leading ", edgeDistances.leading, " trailing ", edgeDistances.trailing)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        print("self.imageContainerView.frame.size.width ", self.imageContainerView.frame.size.width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupUI() {
        imageView.image = pickedImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageCropOverlayView.isUserInteractionEnabled = false
        

        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        
        self.view.layoutIfNeeded()

        self.imageViewWidthConstraint.constant = self.imageContainerView.frame.size.width
        self.imageViewHeightConstraint.constant = self.imageContainerView.frame.size.height
        
        self.view.layoutIfNeeded()
                
        OriginalSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
    }
    
    private func bindData() {
        DataManager.shared.prepareDatasource()
        selectedAspectRatio = (pickedImage.size.width/pickedImage.size.height)
        
        
        if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
            selectedUniqueAspectIdentifier = aspectData[selectedAspectIndex].selectedImage
        } else {
            selectedUniqueAspectIdentifier = "Standard Original S" // used image to identify
        }
    }
    
    private func addGestures() {
        let pinches = UIPinchGestureRecognizer(target: self, action: #selector(pinchV4))
        imageContainerView.addGestureRecognizer(pinches)
        
        let drags = UIPanGestureRecognizer(target: self, action: #selector(drag))
        imageContainerView.addGestureRecognizer(drags)
    }
    
    private func loadCollectionViews() {
        appCollectionView = UICollectionView(frame: appContainerView.bounds, collectionViewLayout: CustomCompositionalLayout.appLayout)
        appCollectionView.register(UINib(nibName: "AppCell", bundle: nil), forCellWithReuseIdentifier: AppCell.identifier)
        appCollectionView.delegate = self
        appCollectionView.dataSource = self
        appCollectionView.isScrollEnabled = false
        appCollectionView.allowsMultipleSelection = false
        appCollectionView.contentInset = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        appCollectionView.backgroundColor = UIColor(red: 0.094, green: 0.098, blue: 0.110, alpha: 1)

        appContainerView.addSubview(appCollectionView)
        appCollectionView.selectItem(at: IndexPath(item: selectedAppIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
                
        aspectCollectionView = UICollectionView(frame: aspectContainerView.bounds, collectionViewLayout: CustomCompositionalLayout.aspectLayout)
        aspectCollectionView.register(UINib(nibName: "AspectCellV2", bundle: nil), forCellWithReuseIdentifier: AspectCellV2.identifier)
        aspectCollectionView.delegate = self
        aspectCollectionView.dataSource = self
        aspectCollectionView.isScrollEnabled = false
        aspectCollectionView.allowsMultipleSelection = false
        aspectCollectionView.backgroundColor = UIColor(red: 0.094, green: 0.098, blue: 0.110, alpha: 1)
        
        aspectContainerView.addSubview(aspectCollectionView)
        aspectCollectionView.selectItem(at: IndexPath(item: selectedAspectIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func configAdPopup() {
//        adPopupView.frame = view.bounds
//        view.addSubview(adPopupView)
        
        adPopupView.addToWindow()
        
        adPopupView.closePressed = {
            print("closeButtonPressed")
            self.adPopupView.hide() {}
        }
        
        adPopupView.purchasePressed = {
            print("purchaseButtonPressed")
            self.pushPurchaseViewController()
        }
        
        adPopupView.adPressed = {
            print("adButtonPressed")
            if ADManager.shared.isAdLimitReached {
                self.adLimitView.show() {}
            } else {
                self.adPopupView.hide {
                    self.calculateRelativeParameters()
                    self.calculateRatioParameters()
                    self.presentProgressViewController()
                }
            }
        }
    }
    
    private func configAdLimitPopup() {
//        adLimitView.frame = view.bounds
//        view.addSubview(adLimitView)
        
        adLimitView.addToWindow()
        
        adLimitView.closePressed = {
            print("closeButtonPressed")
            self.adLimitView.hide() {}
        }
        
        adLimitView.purchasePressed = {
            print("purchaseButtonPressed")
            self.pushPurchaseViewController()
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
        
        VC.relativeWidthFactor = relativeWidthFactor
        VC.relativeHeightFactor = relativeHeightFactor
        VC.relativeCenterXFactor = relativeCenterXFactor
        VC.relativeCenterYFactor = relativeCenterYFactor
        
//        VC.centerOffset = CGPoint(x: imageViewHorizontalConstraint.constant, y: imageViewVerticalConstraint.constant)3

        VC.selectedAspectRatio = selectedAspectRatio
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: false)
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
                self.adLimitView.hide(delay: 0.4) {
                    self.adPopupView.hide(delay: 0.4) {}                    
                }
            }
        }
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
    
    private func calculateRelativeParameters() {
        let containerWidth = imageContainerView.bounds.width
        let containerHeight = imageContainerView.bounds.height
        print("containerWidth B ", containerWidth, " containerHeight B ", imageContainerView.frame.height)
//        print("containerWidth F ",  imageContainerView.frame.width, " containerHeight F ", containerHeight)
        let imageViewWidth = imageView.bounds.width
        let imageViewHeight = imageView.bounds.height
        
        print("imageViewWidth B ", imageView.bounds.width, " imageViewHeight B ", imageView.bounds.height)
//        print("imageViewWidth F ",  imageViewWidth, " imageViewHeight F ", imageViewHeight)
        
//        relativeWidthFactor = imageViewWidth / containerWidth
//        relativeHeightFactor = imageViewHeight / containerHeight
        
        relativeWidthFactor = containerWidth / imageViewWidth
        relativeHeightFactor = containerHeight / imageViewHeight
        print("relativeWidthFactor ",  relativeWidthFactor, " relativeHeightFactor ", relativeHeightFactor)
        
        
        
        
        let imageViewCenterXF = imageView.frame.midX
        let imageViewCenterYF = imageView.frame.midY
        
        
        
        let containerCenterXB = imageContainerView.bounds.midX
        let containerCenterYB = imageContainerView.bounds.midY
        
//        relativeCenterXFactor = containerCenter.x / imageViewCenter.x
//        relativeCenterYFactor = containerCenter.y / imageViewCenter.y
        
        relativeCenterXFactor = containerCenterXB / imageViewCenterXF
        relativeCenterYFactor = containerCenterYB / imageViewCenterYF
//        
//        relativeCenterXFactor = imageViewCenterXF / imageContainerView.bounds.width
//        relativeCenterYFactor = imageViewCenterYF / imageContainerView.bounds.height
        
        
        print("relativeCenterXFBFactor ", relativeCenterXFactor , " relativeCenterBYFactor ", relativeCenterYFactor)
    }
    
    private func calculateRatioParameters() {
        let containerWidth = imageContainerView.bounds.width
        let containerHeight = imageContainerView.bounds.height
        let imageViewWidth = imageView.frame.width
        let imageViewHeight = imageView.frame.height

        // When imageView center is fixed
//        let topConstraint = (containerHeight - imageViewHeight) / 2
//        let bottomConstraint = (containerHeight - imageViewHeight) / 2
//        let leftConstraint = (containerWidth - imageViewWidth) / 2
//        let rightConstraint = (containerWidth - imageViewWidth) / 2
        
        // When imageView center is unbounded
        guard let edgeDistance = imageView.edgeDistancesToSuperview() else { return }

        let topConstraint = edgeDistance.top
        let bottomConstraint = edgeDistance.bottom
        let leftConstraint = edgeDistance.leading
        let rightConstraint = edgeDistance.trailing
        
        print("topConstraint: ", topConstraint)
        print("bottomConstraint: ", bottomConstraint)
        print("leftConstraint: ", leftConstraint)
        print("rightConstraint: ", rightConstraint)

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
              let heightRatio = Float(components[1])
        else { return 1.0 }
        
        // Perform the division
        return CGFloat(widthRatio / heightRatio)
    }
    
    private func convertResolution(resolution: String) -> (width: CGFloat, height: CGFloat) {
        // Handle the special case of "Original"
        if resolution.lowercased() == "original" {
            return (width: pickedImage.size.width, height: pickedImage.size.height)
        }
        
        // Split the string by the colon character
        let components = resolution.split(separator: "x")
        
        // Ensure there are exactly two components
        guard components.count == 2,
              let widthVal = Float(components[0]),
              let heightVal = Float(components[1])
        else { return (width: pickedImage.size.width, height: pickedImage.size.height) }
        
        return (width: CGFloat(widthVal), height: CGFloat(heightVal))
    }
    
    let minimumDistance = 50.0
    
    private func alignmentVisibility() {
        centerXAxisView.isHidden = centerXAxisView.frame.contains(imageView.center) ? false : true
        centerYAxisView.isHidden = centerYAxisView.frame.contains(imageView.center) ? false : true
        
        if !centerXAxisView.isHidden || !centerYAxisView.isHidden {
            let distanceXAxisView = centerXAxisView.distanceFromCenter(to: imageView.center)
            let distanceYAxisView = centerYAxisView.distanceFromCenter(to: imageView.center)
            
//            if distanceXAxisView < minimumDistance || distanceYAxisView < minimumDistance {
            
            if centerXAxisView.frame.contains(imageView.center) || centerYAxisView.frame.contains(imageView.center) {
//            if imageViewHorizontalConstraint.constant == 0 || imageViewVerticalConstraint.constant == 0 {
                generator.impactOccurred()
            }
        }
    }
    
    private func updateAlignment() {
        imageViewHorizontalConstraint.constant = centerXAxisView.frame.contains(imageView.center) ? 0 : imageViewHorizontalConstraint.constant
        imageViewVerticalConstraint.constant = centerYAxisView.frame.contains(imageView.center) ? 0 : imageViewVerticalConstraint.constant
        
        self.view.layoutIfNeeded()
        
        centerXAxisView.isHidden = true
        centerYAxisView.isHidden = true
        
//        if imageViewHorizontalConstraint.constant == 0 || imageViewVerticalConstraint.constant == 0 {
//            generator.impactOccurred()
//        }

    }
    
    var initalOffSet: CGPoint! = CGPoint(x: 0, y: 0)
    var lastOffSet: CGPoint! = CGPoint(x: 0, y: 0)
    
    @objc func drag(gest:UIPanGestureRecognizer) {
        self.view.layoutIfNeeded()
        
        let translation = gest.translation(in: self.view)
        switch (gest.state) {
        case .began:
            initalOffSet = CGPoint(x: imageViewHorizontalConstraint.constant, y: imageViewVerticalConstraint.constant)
            break
            
        case .changed:
            let newX = initalOffSet.x + translation.x
            let newY = initalOffSet.y + translation.y
            
            print("initalOffSet.x ", initalOffSet.x, " initalOffSet.y ", initalOffSet.y)
            print("newX ", newX, " newY ", newY)
            
            let boundX = (imageContainerView.frame.width - imageView.frame.width)/2
            let boundY = (imageContainerView.frame.height - imageView.frame.height)/2
            
            
            imageViewHorizontalConstraint.constant = min(max(newX, -boundX), boundX)
            imageViewVerticalConstraint.constant = min(max(newY, -boundY), boundY)
            
            print("Horizontal ", imageViewHorizontalConstraint.constant, " Vertical ", imageViewVerticalConstraint.constant)
            
            
            alignmentVisibility()
            self.view.layoutIfNeeded()
            break
            
        case .ended:
            lastOffSet = CGPoint(x: imageViewHorizontalConstraint.constant, y: imageViewVerticalConstraint.constant)
            
            updateAlignment()
            break
            
        default:
            break
        }
        
    }

    var viewSize: CGSize!
    var OriginalSize : CGSize!
    var minScale: CGFloat = 0.5
    var maxScale: CGFloat = 1.0

    @objc func pinch(gest:UIPinchGestureRecognizer) {
        self.view.layoutIfNeeded()
        let scale = gest.scale
        switch (gest.state) {
        case .began:
//            viewSize = CGSize(width: imageViewWidthConstraint.constant, height: imageView.frame.size.height)
            viewSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
            break
            
        case .changed:
            let boundX = (imageContainerView.frame.width - imageView.frame.width)/2
            let boundY = (imageContainerView.frame.height - imageView.frame.height)/2
            
            
            let newX = imageViewHorizontalConstraint.constant * scale
            let newY = imageViewVerticalConstraint.constant * scale
//            
            
            if let edgeDistances = imageView.edgeDistancesToSuperview() {
                print("top ", edgeDistances.top, " bottom ", edgeDistances.bottom, " leading ", edgeDistances.leading, " trailing ", edgeDistances.trailing)

                if abs(imageViewHorizontalConstraint.constant) <= abs(boundX) || abs(imageViewVerticalConstraint.constant) <= abs(boundY) {
                    
                    if scale > 1.0 {
                        
                        if (edgeDistances.top <= 0 && edgeDistances.leading <= 0) || (edgeDistances.top <= 0 && edgeDistances.trailing <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.leading <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.trailing <= 0) {
                            // any two sides // corners touching
                            imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
                            imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                            
                        }
                        
                        else if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 || edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                            // any side touching
                            if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 {
                                // vartical
                                if edgeDistances.top <= 0 {
                                    imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                                }
                                else if edgeDistances.bottom <= 0 {
                                    imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                                }
                            }
                            else if edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                                // horizontal
                                if edgeDistances.leading <= 0 {
                                    imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
                                }
                                else if edgeDistances.trailing <= 0 {
                                    imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
                                }
                            }
                        }
                        else if edgeDistances.top <= 0 && edgeDistances.bottom <= 0 && edgeDistances.leading <= 0 && edgeDistances.trailing <= 0 {
                            // all side touching //center
                            imageViewHorizontalConstraint.constant = 0
                            imageViewVerticalConstraint.constant = 0
                        }
                        else if edgeDistances.top > 0 && edgeDistances.bottom > 0 && edgeDistances.leading > 0 && edgeDistances.trailing > 0 {
                            imageViewHorizontalConstraint.constant = imageViewHorizontalConstraint.constant
                            imageViewVerticalConstraint.constant = imageViewVerticalConstraint.constant
                        }
                    }
                }
                else {
                    // out of boundary
                }
                
                
                
                
                
////                if edgeDistances.top != 0 && edgeDistances.bottom != 0 && edgeDistances.leading != 0 && edgeDistances.trailing != 0 {
//                    // not all edge touvhing container . for initial fit config
//                    
//                    if edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
//                        imageViewHorizontalConstraint.constant = (temp.x + newX)
////                        imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
////                        imageViewHorizontalConstraint.constant = max((imageViewHorizontalConstraint.constant + newX), temp.x)
//                    } else {
//                        imageViewHorizontalConstraint.constant = temp.x
//                    }
//                
//                    if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 {
//                        imageViewVerticalConstraint.constant = (temp.y + newY)
////                        imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
////                        imageViewVerticalConstraint.constant = max((imageViewVerticalConstraint.constant + newY), temp.y)
//                    } else {
//                        imageViewVerticalConstraint.constant = temp.y
//                    }
//                
////                }
                
            }
            
            
            print (" ++ imageViewHorizontalConstraint.constant ", imageViewHorizontalConstraint.constant)

            let newWidth = viewSize.width * scale
            print("               newWidth", newWidth)
            if newWidth >= OriginalSize.width * minScale {
                imageViewWidthConstraint.constant = newWidth
            }
            
            alignmentVisibility()
            
            self.view.layoutIfNeeded()
            break
            
        case .ended:
            updateAlignment()
            break
            
        default:
            break
        }
    }
    
    
    func pointDistance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {        
        // Calculate the differences in x and y
        let deltaX = point1.x - point2.x
        let deltaY = point1.y - point2.y
        
        // Use hypot to calculate the distance
        return hypot(deltaX, deltaY)
    }
    
    
    @objc func pinchV2(gest:UIPinchGestureRecognizer) {
        self.view.layoutIfNeeded()
        let scale = gest.scale
        switch (gest.state) {
        case .began:
            viewSize = CGSize(width: imageViewWidthConstraint.constant, height: imageView.frame.size.height)
            initialCenter = CGPoint(x: imageViewHorizontalConstraint.constant, y: imageViewVerticalConstraint.constant)
            print(" ++++    initialCenter X", initialCenter.x, " initialCenter y ", initialCenter.y)

            break
            
        case .changed:
            let boundX = (imageContainerView.frame.width - imageView.frame.width)/2
            let boundY = (imageContainerView.frame.height - imageView.frame.height)/2
            
            let newX = initialCenter.x * scale
            let newY = initialCenter.y * scale
            let newWidth = viewSize.width * scale
            
            let finalX = abs(newX - initialCenter.x)
            let finalY = abs(newY - initialCenter.y)
            
            

//            print(" ####    boundX ", boundX, " boundY ", boundY)
//            print(" ++++    imageViewHorizontalConstraint.constant ", imageViewHorizontalConstraint.constant + newX)
//            print(" ++++    imageViewVerticalConstraint.constant ", imageViewVerticalConstraint.constant + newY)
//            print(" ++++    newWidth ", newWidth, " newX ", newX, " newY ", newY)
            print(" ++++    finalX ", finalX, " finalY ", finalY)

            if newWidth >= OriginalSize.width * minScale && newWidth < OriginalSize.width * 1.0 {

                imageViewWidthConstraint.constant = newWidth
                
                if let edgeDistances = imageView.edgeDistancesToSuperview() {

//                    if abs(imageViewHorizontalConstraint.constant) < abs(boundX) || abs(imageViewVerticalConstraint.constant) < abs(boundY) {
                    if imageContainerView.frame.size.height >= imageView.frame.size.height && imageContainerView.frame.size.width >= imageView.frame.size.width {
                        
                        
                        if scale > 1.0 { // zoom in
                            
                            if (edgeDistances.top <= 0 && edgeDistances.leading <= 0) || (edgeDistances.top <= 0 && edgeDistances.trailing <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.leading <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.trailing <= 0) {
                                // any two sides // corners touching
                                
                                if (edgeDistances.top <= 0 && edgeDistances.leading <= 0) {
                                    if imageViewHorizontalConstraint.constant != 0 {
                                        imageViewHorizontalConstraint.constant = initialCenter.x + finalX
                                    }
                                    if imageViewVerticalConstraint.constant != 0 {
                                        imageViewVerticalConstraint.constant = initialCenter.y + finalY
                                    }
                                }
                                else if (edgeDistances.top <= 0 && edgeDistances.trailing <= 0) {
                                    if imageViewHorizontalConstraint.constant != 0 {
                                        imageViewHorizontalConstraint.constant = initialCenter.x - finalX
                                    }
                                    
                                    if imageViewVerticalConstraint.constant != 0 {
                                        imageViewVerticalConstraint.constant = initialCenter.y + finalY
                                    }
                                }
                                else if (edgeDistances.bottom <= 0 && edgeDistances.leading <= 0) {
                                    
                                    if imageViewHorizontalConstraint.constant != 0 {
                                        imageViewHorizontalConstraint.constant = initialCenter.x + finalX
                                    }
                                    if imageViewVerticalConstraint.constant != 0 {
                                        imageViewVerticalConstraint.constant = initialCenter.y - finalY
                                    }
                                }
                                else if (edgeDistances.bottom <= 0 && edgeDistances.trailing <= 0) {
                                    if imageViewHorizontalConstraint.constant != 0 {
                                        imageViewHorizontalConstraint.constant = initialCenter.x - finalX
                                    }
                                    if imageViewVerticalConstraint.constant != 0 {
                                        imageViewVerticalConstraint.constant = initialCenter.y - finalY
                                    }
                                }
                            }
                            
                            else if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 || edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                                // any side touching
                                if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 {
                                    // vartical
                                    if imageViewVerticalConstraint.constant != 0 {
                                        if edgeDistances.top <= 0 {
                                            imageViewVerticalConstraint.constant = initialCenter.y + finalY
                                        }
                                        else if edgeDistances.bottom <= 0 {
                                            imageViewVerticalConstraint.constant = initialCenter.y - finalY
                                        }
                                    }
                                }
                                else if edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                                    // horizontal
                                    if imageViewHorizontalConstraint.constant != 0 {
                                        if edgeDistances.leading <= 0 {
                                            imageViewHorizontalConstraint.constant = initialCenter.x + finalX
                                        }
                                        else if edgeDistances.trailing <= 0 {
                                            imageViewHorizontalConstraint.constant = initialCenter.x - finalX
                                        }
                                    }
                                }
                            }
                            else if edgeDistances.top <= 0 && edgeDistances.bottom <= 0 && edgeDistances.leading <= 0 && edgeDistances.trailing <= 0 {
                                // all side touching //center
                                imageViewHorizontalConstraint.constant = 0
                                imageViewVerticalConstraint.constant = 0
                            }
                            
                        }
                        else {
                            // zoom out
    //                            imageViewWidthConstraint.constant = newWidth
                        }
                    }
//                    }
//                    else {
//                        // out of boundary
//    
//                    }
//                    
                    
                    
                }
            }
            
            
            
            print(" ----    imageViewHorizontalConstraint.constant ", imageViewHorizontalConstraint.constant)
            print(" ----    imageViewVerticalConstraint.constant ", imageViewVerticalConstraint.constant)
            print(" ----    imageViewWidthConstraint.constant ",  imageViewWidthConstraint.constant)
            
            alignmentVisibility()
            
            self.view.layoutIfNeeded()
            break
            
        case .ended:
            updateAlignment()
            break
            
        default:
            break
        }
    }
    
    
    
    
    @objc func pinchV3(gest:UIPinchGestureRecognizer) {
        self.view.layoutIfNeeded()
        let scale = gest.scale
        switch (gest.state) {
        case .began:
            viewSize = CGSize(width: imageViewWidthConstraint.constant, height: imageView.frame.size.height)
            break
            
        case .changed:
            let boundX = (imageContainerView.frame.width - imageView.frame.width)/2
            let boundY = (imageContainerView.frame.height - imageView.frame.height)/2
            
            let newX = imageViewHorizontalConstraint.constant * scale
            let newY = imageViewVerticalConstraint.constant * scale
            let newWidth = viewSize.width * scale
                        
            
            print(" ####    boundX ", boundX, " boundY ", boundY)
            print(" ++++    imageViewHorizontalConstraint.constant ", imageViewHorizontalConstraint.constant + newX)
            print(" ++++    imageViewVerticalConstraint.constant ", imageViewVerticalConstraint.constant + newY)
            print(" ++++    newWidth ", newWidth, " newX ", newX, " newY ", newY)

            if newWidth >= OriginalSize.width * minScale {
                
                
                if let edgeDistances = imageView.edgeDistancesToSuperview() {
                    print("top ", edgeDistances.top, " bottom ", edgeDistances.bottom, " leading ", edgeDistances.leading, " trailing ", edgeDistances.trailing)


                        if scale > 1.0 { // zoom in
                            
                            if (edgeDistances.top <= 0 && edgeDistances.leading <= 0) || (edgeDistances.top <= 0 && edgeDistances.trailing <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.leading <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.trailing <= 0) {
                                // any two sides // corners touching
//                                imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
//                                imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                                if abs(imageViewHorizontalConstraint.constant) <= abs(boundX) {
//                                    imageViewHorizontalConstraint.constant = (newX)
                                    imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
                                }
                                
                                if abs(imageViewVerticalConstraint.constant) <= abs(boundY) {
//                                    imageViewVerticalConstraint.constant = (newY)
                                    imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                                }
                                
                                imageViewWidthConstraint.constant = newWidth
                            }
                            
                            else if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 || edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                                // any side touching
                                if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 {
                                    // vartical
                                    if edgeDistances.top <= 0 {
                                        if abs(imageViewVerticalConstraint.constant) <= abs(boundY) {
                                            imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                                        }
                                    }
                                    else if edgeDistances.bottom <= 0 {
                                        if abs(imageViewVerticalConstraint.constant) <= abs(boundY) {
                                            imageViewVerticalConstraint.constant = (imageViewVerticalConstraint.constant + newY)
                                        }
                                    }
                                    
                                    imageViewWidthConstraint.constant = newWidth
                                }
                                else if edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                                    // horizontal
                                    if edgeDistances.leading <= 0 {
                                        if abs(imageViewHorizontalConstraint.constant) <= abs(boundX) {
                                            imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
                                        }
                                    }
                                    else if edgeDistances.trailing <= 0 {
                                        if abs(imageViewHorizontalConstraint.constant) <= abs(boundX) {
                                            imageViewHorizontalConstraint.constant = (imageViewHorizontalConstraint.constant + newX)
                                        }
                                    }
                                    
                                    imageViewWidthConstraint.constant = newWidth
                                }
                            }
                            else if edgeDistances.top <= 0 && edgeDistances.bottom <= 0 && edgeDistances.leading <= 0 && edgeDistances.trailing <= 0 {
                                // all side touching //center
                                imageViewHorizontalConstraint.constant = 0
                                imageViewVerticalConstraint.constant = 0
                            }
                            else if edgeDistances.top > 0 && edgeDistances.bottom > 0 && edgeDistances.leading > 0 && edgeDistances.trailing > 0 {
                                // all side inside bounds
                                imageViewHorizontalConstraint.constant = imageViewHorizontalConstraint.constant
                                imageViewVerticalConstraint.constant = imageViewVerticalConstraint.constant
                                imageViewWidthConstraint.constant = newWidth
                            }
                            else {
                                imageViewHorizontalConstraint.constant = imageViewHorizontalConstraint.constant
                                imageViewVerticalConstraint.constant = imageViewVerticalConstraint.constant
                            }
                        }
                        else {
                            // zoom out
                            imageViewWidthConstraint.constant = newWidth
                        }
                    
//                    }
//                    else {
//                        // out of boundary
//
//                    }
                    
                    
                    
                }
            }
            
            
            
            print(" ----    imageViewHorizontalConstraint.constant ", imageViewHorizontalConstraint.constant)
            print(" ----    imageViewVerticalConstraint.constant ", imageViewVerticalConstraint.constant)
            print(" ----    imageViewWidthConstraint.constant ",  imageViewWidthConstraint.constant)
            
            alignmentVisibility()
            
            self.view.layoutIfNeeded()
            break
            
        case .ended:
            updateAlignment()
            break
            
        default:
            break
        }
    }
    
    
    
    
    
    var initialCenter: CGPoint = CGPoint(x: 0, y: 0)
    
    @objc func pinchV4(gest:UIPinchGestureRecognizer) {
        self.view.layoutIfNeeded()
        let scale = gest.scale
        switch (gest.state) {
        case .began:
            viewSize = CGSize(width: imageViewWidthConstraint.constant, height: imageViewHeightConstraint.constant)

            break
            
        case .changed:
            let newWidth = viewSize.width * scale
            let newHeight = viewSize.height * scale
            
            if let edgeDistances = imageView.edgeDistancesToSuperview() {
                
                // detect zoom in or out
                // determine height or width is greater
                // apply min scale limit on that
                // apply max scale limit on that
                // compare within bounds than changee width height constraint
                
                // MARK: zoom in > 1.0
                if scale > 1.0 { 
                    // zoom in

                    // MARK: Height Width Constraints
                    
                    if imageContainerView.frame.width <= imageContainerView.frame.height {
                        // width small //equal
                        if newWidth <= imageContainerView.frame.width * maxScale {
                            imageViewWidthConstraint.constant = newWidth
                            imageViewHeightConstraint.constant = newHeight
                        } else {
                            // max width manual
                            imageViewWidthConstraint.constant = imageContainerView.frame.width
                            imageViewHeightConstraint.constant = imageViewWidthConstraint.constant * (1/(pickedImage.size.width/pickedImage.size.height))
                        }
                    }
                    else if imageContainerView.frame.height < imageContainerView.frame.width {
                        // height small
                        if newHeight <= imageContainerView.frame.height * maxScale {
                            imageViewWidthConstraint.constant = newWidth
                            imageViewHeightConstraint.constant = newHeight
                        } else {
                            // max height manual
                            imageViewHeightConstraint.constant = imageContainerView.frame.height
                            imageViewWidthConstraint.constant = imageViewHeightConstraint.constant * (pickedImage.size.width/pickedImage.size.height)
                        }
                    }
                    
                    
                    // MARK: Center Constaints
                    
                    let boundX = (imageContainerView.frame.width - (imageViewWidthConstraint.constant/2))
                    let boundY = (imageContainerView.frame.height - (imageViewHeightConstraint.constant/2))
                    
                    let centerX = boundX - imageContainerView.frame.width/2
                    let centerY = boundY - imageContainerView.frame.height/2
                    
//                    print(" ####    boundX ", boundX, " boundY ", boundY)
//                    print(" ####    centerX ", centerX, " centerY ", centerY)
                    
                    if (edgeDistances.top <= 0 && edgeDistances.leading <= 0) || (edgeDistances.top <= 0 && edgeDistances.trailing <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.leading <= 0) || (edgeDistances.bottom <= 0 && edgeDistances.trailing <= 0) {
                        // any two sides // corners touching
                        
                        if (edgeDistances.top <= 0 && edgeDistances.leading <= 0) {
                            if imageViewHorizontalConstraint.constant != 0 {
                                imageViewHorizontalConstraint.constant = -centerX
                            }
                            if imageViewVerticalConstraint.constant != 0 {
                                imageViewVerticalConstraint.constant = -centerY
                            }
                        }
                        else if (edgeDistances.top <= 0 && edgeDistances.trailing <= 0) {
                            if imageViewHorizontalConstraint.constant != 0 {
                                imageViewHorizontalConstraint.constant = centerX
                            }
                            if imageViewVerticalConstraint.constant != 0 {
                                imageViewVerticalConstraint.constant = -centerY
                            }
                        }
                        else if (edgeDistances.bottom <= 0 && edgeDistances.leading <= 0) {
                            if imageViewHorizontalConstraint.constant != 0 {
                                imageViewHorizontalConstraint.constant = -centerX
                            }
                            if imageViewVerticalConstraint.constant != 0 {
                                imageViewVerticalConstraint.constant = centerY
                            }
                        }
                        else if (edgeDistances.bottom <= 0 && edgeDistances.trailing <= 0) {
                            if imageViewHorizontalConstraint.constant != 0 {
                                imageViewHorizontalConstraint.constant = centerX
                            }
                            if imageViewVerticalConstraint.constant != 0 {
                                imageViewVerticalConstraint.constant = centerY
                            }
                        }
                    }
                    
                    else if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 || edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                        // any side touching
                        if edgeDistances.top <= 0 || edgeDistances.bottom <= 0 {
                            // vertical
                            if imageViewVerticalConstraint.constant != 0 {
                                if edgeDistances.top <= 0 {
                                    imageViewVerticalConstraint.constant = -centerY
                                } else if edgeDistances.bottom <= 0 {
                                    imageViewVerticalConstraint.constant = centerY
                                }
                            }
                        }
                        else if edgeDistances.leading <= 0 || edgeDistances.trailing <= 0 {
                            // horizontal
                            if imageViewHorizontalConstraint.constant != 0 {
                                if edgeDistances.leading <= 0 {
                                    imageViewHorizontalConstraint.constant = -centerX
                                } else if edgeDistances.trailing <= 0 {
                                    imageViewHorizontalConstraint.constant = centerX
                                }
                            }
                        }
                    }
                    
                    else if edgeDistances.top <= 0 && edgeDistances.bottom <= 0 && edgeDistances.leading <= 0 && edgeDistances.trailing <= 0 {
                        // all side touching //center
                        imageViewHorizontalConstraint.constant = 0
                        imageViewVerticalConstraint.constant = 0
                    }
                    
                }
                
                
                // MARK: zoom out < 1.0
                else if scale < 1.0 {
                    // zoom out
                    
                    // MARK: Height Width Constaints
                    
                    if imageContainerView.frame.width >= imageContainerView.frame.height {
                        // width big //equal
                        if newWidth >= OriginalSize.width * minScale {
                            imageViewWidthConstraint.constant = newWidth
                            imageViewHeightConstraint.constant = newHeight
                        }
                    }
                    else if imageContainerView.frame.height > imageContainerView.frame.width {
                        // height big
                        if newHeight >= OriginalSize.height * minScale {
                            imageViewWidthConstraint.constant = newWidth
                            imageViewHeightConstraint.constant = newHeight
                        }
                    }
                    
                }
                else {
                    // no zoom in out
                }
            }
            
            print(" ----    imageViewHorizontalConstraint.constant ", imageViewHorizontalConstraint.constant)
            print(" ----    imageViewVerticalConstraint.constant ", imageViewVerticalConstraint.constant)
            print(" ----    imageViewWidthConstraint.constant ",  imageViewWidthConstraint.constant)
            print(" ----    imageViewHeightConstraint.constant ",  imageViewHeightConstraint.constant)
            
            alignmentVisibility()
            
            self.view.layoutIfNeeded()
            break
            
        case .ended:
//            updateAlignment()
            break
            
        default:
            break
        }
    }
    
    
    
    
    @IBAction func apiButtonPressed(_ sender: Any) {
        if PurchaseManager.shared.isPremiumUser { // premium
            calculateRelativeParameters()
            calculateRatioParameters()
            presentProgressViewController()
        } else { // free
            adPopupView.show() {}
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ExpandViewControllerV2: UICollectionViewDataSource {
    
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
                cell.setup(title: appData.title)
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AspectCellV2.identifier, for: indexPath) as? AspectCellV2 else { return UICollectionViewCell() }
                        
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                cell.setup(selectedImage: aspectData[indexPath.item].selectedImage, nonSelectedImage: aspectData[indexPath.item].nonSelectedImage)
                
            }
            return cell
        }
    }
    
}

extension ExpandViewControllerV2: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt", indexPath)
        
        if collectionView == appCollectionView {
            selectedAppIndex = indexPath.item
            
            aspectCollectionView.reloadData()
        
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex), indexPath.item == selectedAppIndex, aspectData.count > selectedAspectIndex, selectedUniqueAspectIdentifier.lowercased() == aspectData[selectedAspectIndex].selectedImage.lowercased() {
                
                print("aspectData ", aspectData.count, " selectedAspectIndex ", selectedAspectIndex)
                
                aspectCollectionView.selectItem(at: IndexPath(item: selectedAspectIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            }
        }
        
        else if collectionView == aspectCollectionView {
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                selectedAspectRatio = convertRatio(ratio: aspectData[indexPath.item].ratio)
                print("selectedAspectRatio ", selectedAspectRatio ?? -1.0)
                
                selectedUniqueAspectIdentifier = aspectData[indexPath.item].selectedImage
                
                aspectData[indexPath.item].text.lowercased() == "profile" ? addMaskToCanvas() : removeMaskFromCanvas()
            }
            
            selectedAspectIndex = indexPath.item
            aspectCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                self.imageViewHorizontalConstraint.constant =  0
                self.imageViewVerticalConstraint.constant = 0
                
                self.view.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                let newContainerSize = CGSize(width: self.imageContainerView.bounds.size.width, height: self.imageContainerView.bounds.size.width*(1/self.selectedAspectRatio))
                let aspectrectContainer = AVMakeRect(aspectRatio: newContainerSize, insideRect: self.canvasView.bounds)
                let imageaspectrectContainer = AVMakeRect(aspectRatio: self.imageView.bounds.size, insideRect: aspectrectContainer)

                self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio))
                self.imageViewWidthConstraint.constant = imageaspectrectContainer.size.width
                self.imageViewHeightConstraint.constant = imageaspectrectContainer.size.height
                
                self.canvasView.layoutIfNeeded()
            }
        }
    }
}


extension ExpandViewControllerV2: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
