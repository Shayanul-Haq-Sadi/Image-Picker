//
//  ExpandViewControllerV2.swift
//  Image Picker
//
//  Created by BCL Device-18 on 3/7/24.
//

import UIKit
import AVFoundation
import Reachability

class ExpandViewControllerV2: UIViewController {
    
    static let identifier = "ExpandViewControllerV2"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    
    @IBOutlet private weak var TransparentImageView: UIImageView!
    @IBOutlet private weak var centerXAxisView: UIView!
    @IBOutlet private weak var centerYAxisView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageCropOverlayView: CropOverlayView!
    
    @IBOutlet private weak var imageContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageContainerViewWidthConstraint: NSLayoutConstraint!
//    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewVerticalConstraint: NSLayoutConstraint!
    
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

    var selectedAspectRatio: CGFloat!
    var relativeScaleFactor: CGFloat!

    private var selectedAppIndex: Int = 0
    private var selectedAspectIndex: Int = 0
    private var selectedUniqueAspectIdentifier: String!
    
    private var generator : UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var isSetupDone: Bool = false
    var isProfileType: Bool = false
    
    //declare this property where it won't go out of scope relative to your listener
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appCollectionView.frame = appContainerView.bounds
        aspectCollectionView.frame = aspectContainerView.bounds
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if !isSetupDone {
            setupUI() // bool check for the first timer
            isSetupDone = true
        }
    }
    
    private func setupUI() {
        imageView.image = pickedImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageCropOverlayView.isUserInteractionEnabled = false
        
//        self.imageContainerViewWidthConstraint.constant = SCREEN_WIDTH
        self.imageContainerViewWidthConstraint.constant = canvasView.bounds.size.width
        self.imageContainerViewHeightConstraint.constant = canvasView.bounds.size.height
        self.view.layoutIfNeeded()

        let newContainerSize = CGSizeMake(self.imageContainerView.bounds.size.width, self.imageContainerView.bounds.size.width*(1/self.selectedAspectRatio))
        var aspectrectContainer = AVMakeRect(aspectRatio: newContainerSize, insideRect: self.canvasView.bounds)
//        aspectrectContainer = CGRectMake(aspectrectContainer.origin.x, aspectrectContainer.origin.y, floor((aspectrectContainer.size.width)),floor((aspectrectContainer.size.height)))
        
        self.imageContainerViewWidthConstraint.constant = aspectrectContainer.size.width
        self.imageContainerViewHeightConstraint.constant = aspectrectContainer.size.height
//        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()

        self.imageViewWidthConstraint.constant = self.imageContainerView.frame.size.width
        self.imageViewHeightConstraint.constant = self.imageContainerView.frame.size.height
        self.view.layoutIfNeeded()
                
        OriginalSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
        OriginalSelectedSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
    }
    
    private func updateUI() {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            let newContainerSize = CGSizeMake(self.imageContainerView.bounds.size.width, self.imageContainerView.bounds.size.width*(1/self.selectedAspectRatio))
            var aspectrectContainer = AVMakeRect(aspectRatio: newContainerSize, insideRect: self.canvasView.bounds)
//            aspectrectContainer = CGRectMake(aspectrectContainer.origin.x, aspectrectContainer.origin.y, floor((aspectrectContainer.size.width)),floor((aspectrectContainer.size.height)))
            let imageaspectrectContainer = AVMakeRect(aspectRatio: self.imageView.bounds.size, insideRect: aspectrectContainer)
            
            self.imageContainerViewWidthConstraint.constant = aspectrectContainer.size.width
            self.imageContainerViewHeightConstraint.constant = aspectrectContainer.size.height
//                self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio))
            self.view.layoutIfNeeded()
            
            self.imageViewWidthConstraint.constant = imageaspectrectContainer.size.width
            self.imageViewHeightConstraint.constant = imageaspectrectContainer.size.height
            self.imageViewHorizontalConstraint.constant = 0
            self.imageViewVerticalConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.OriginalSelectedSize = CGSize(width: self.imageView.frame.size.width, height: self.imageView.frame.size.height)
        }
    }
    
    private func bindData() {
        DataManager.shared.prepareDatasource()
        selectedAspectRatio = (pickedImage.size.width/pickedImage.size.height)
        
        
        if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
            selectedUniqueAspectIdentifier = aspectData[selectedAspectIndex].selectedImage
        } else {
            selectedUniqueAspectIdentifier = "Original S" // used image to identify
        }
    }
    
    private func addGestures() {
        let pinches = UIPinchGestureRecognizer(target: self, action: #selector(pinchV4))
        pinches.delegate = self
        imageContainerView.addGestureRecognizer(pinches)
        
        let drags = UIPanGestureRecognizer(target: self, action: #selector(drag))
        drags.delegate = self
        imageContainerView.addGestureRecognizer(drags)
    }
    
    private func loadCollectionViews() {
        let appLayout = UICollectionViewFlowLayout()
        appLayout.scrollDirection = .horizontal
        
        appCollectionView = UICollectionView(frame: appContainerView.bounds, collectionViewLayout: appLayout)
        appCollectionView.register(UINib(nibName: "AppCell", bundle: nil), forCellWithReuseIdentifier: AppCell.identifier)
        appCollectionView.delegate = self
        appCollectionView.dataSource = self
        appCollectionView.isScrollEnabled = true
        appCollectionView.showsHorizontalScrollIndicator = false
        appCollectionView.allowsMultipleSelection = false
        appCollectionView.backgroundColor = UIColor(red: 0.094, green: 0.098, blue: 0.110, alpha: 1)

        appContainerView.addSubview(appCollectionView)
        appCollectionView.selectItem(at: IndexPath(item: selectedAppIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        
        let aspectLayout = UICollectionViewFlowLayout()
        aspectLayout.scrollDirection = .horizontal
//        aspectLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Enable self-sizing cells
        
        aspectCollectionView = UICollectionView(frame: aspectContainerView.bounds, collectionViewLayout: aspectLayout)
        aspectCollectionView.register(UINib(nibName: "AspectCellV2", bundle: nil), forCellWithReuseIdentifier: AspectCellV2.identifier)
        aspectCollectionView.delegate = self
        aspectCollectionView.dataSource = self
        aspectCollectionView.isScrollEnabled = true
        aspectCollectionView.showsHorizontalScrollIndicator = false
        aspectCollectionView.allowsMultipleSelection = false
        aspectCollectionView.backgroundColor = UIColor(red: 0.094, green: 0.098, blue: 0.110, alpha: 1)
        
        aspectContainerView.addSubview(aspectCollectionView)
        aspectCollectionView.selectItem(at: IndexPath(item: selectedAspectIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func configAdPopup() {
        adPopupView.addToKeyWindow()
        
        adPopupView.closePressed = {
            print("closeButtonPressed")
            self.adPopupView.hide() {}
        }
        
        adPopupView.purchasePressed = {
            print("purchaseButtonPressed")
            self.adPopupView.hide() {
                self.pushPurchaseViewController { delay in
                    if !PurchaseManager.shared.isPremiumUser {
                        self.adPopupView.show(delay: delay) {}
                    }
                }
            }
        }
        
        adPopupView.adPressed = {
            print("adButtonPressed")
            if self.reachability.connection == .unavailable {
                self.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok")
            } else {
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
    }
    
    private func configAdLimitPopup() {
        adLimitView.addToKeyWindow()
        
        adLimitView.closePressed = {
            print("closeButtonPressed")
            self.adLimitView.hide() {}
        }
        
        adLimitView.purchasePressed = {
            print("purchaseButtonPressed")
            self.adLimitView.hide() {
                self.adPopupView.hide() {
                    self.pushPurchaseViewController() { delay in
                        if !PurchaseManager.shared.isPremiumUser {
                            self.adPopupView.show(delay: delay) {
                                self.adLimitView.show() {}
                            }
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
            VC.relativeScaleFactor = relativeScaleFactor
            VC.isFromExapand = true
            
            VC.isProfileType = isProfileType
            
            VC.downloadCompletion = { picked, downloaded in
                self.pushDownloadViewControllerV2(pickedImage: picked, downloadedImage: downloaded)
            }
        }
        
        present(navVC, animated: false)
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
        VC.relativeScaleFactor = relativeScaleFactor
        
        VC.isProfileType = isProfileType
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
    private func pushPurchaseViewController(completion: @escaping (_ delay: Double) -> Void?) { // with present animation
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
            
            completion(0.4)
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
    
    private var OriginalSelectedSize : CGSize!
    
    private func calculateRelativeParameters() {
        relativeScaleFactor = imageView.frame.size.width / OriginalSelectedSize.width
        print("relativeScaleFactor ",  relativeScaleFactor)
    }
    
    private func calculateRatioParameters() {
        let containerWidth = imageContainerView.bounds.width
        let containerHeight = imageContainerView.bounds.height
        let imageViewWidth = imageView.frame.size.width
        let imageViewHeight = imageView.frame.size.height

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
        
        print("%%%%%%%%%%")
        print("topDistance: ", topConstraint, " bottomDistance: ", bottomConstraint, " leftDistance: ", leftConstraint, " rightDistance: ", rightConstraint)

        // Convert to percentages
        
        // non neg
        topRatio = (topConstraint / imageViewHeight)
        bottomRatio = (bottomConstraint / imageViewHeight)
        leftRatio = (leftConstraint / imageViewWidth)
        rightRatio = (rightConstraint / imageViewWidth)
        
        print("Top Percentage: \(String(describing: topRatio)) %")
        print("Bottom Percentage: \(String(describing: bottomRatio)) %")
        print("Left Percentage: \(String(describing: leftRatio)) %")
        print("Right Percentage: \(String(describing: rightRatio)) %")
        print("%%%%%%%%%%")

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
    
    private var initalOffSet: CGPoint! = CGPoint(x: 0, y: 0)
    private var lastOffSet: CGPoint! = CGPoint(x: 0, y: 0)
    
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
            
//            print("initalOffSet.x ", initalOffSet.x, " initalOffSet.y ", initalOffSet.y)
//            print("newX ", newX, " newY ", newY)
            
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

    private var viewSize: CGSize!
    private var OriginalSize : CGSize!
    private var minScale: CGFloat = 0.5
    private var maxScale: CGFloat = 1.0
    
    func pointDistance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {        
        // Calculate the differences in x and y
        let deltaX = point1.x - point2.x
        let deltaY = point1.y - point2.y
        
        // Use hypot to calculate the distance
        return hypot(deltaX, deltaY)
    }
    
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
                    
                    if (newHeight < imageContainerView.frame.height * maxScale && newWidth < imageContainerView.frame.width * maxScale) {
                        imageViewHeightConstraint.constant = newHeight
                        imageViewWidthConstraint.constant = newWidth
                    } else {
                        let imageaspectrectContainer = AVMakeRect(aspectRatio: self.imageView.bounds.size, insideRect: self.imageContainerView.bounds)
                        imageViewWidthConstraint.constant = imageaspectrectContainer.size.width
                        imageViewHeightConstraint.constant = imageaspectrectContainer.size.height
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
                        if newWidth > OriginalSize.width * minScale {
                            imageViewWidthConstraint.constant = newWidth
                            imageViewHeightConstraint.constant = newHeight
                        }
                    }
                    else if imageContainerView.frame.height > imageContainerView.frame.width {
                        // height big
                        if newHeight > OriginalSize.height * minScale {
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
            updateAlignment()
            break
            
        default:
            break
        }
    }
    
    @IBAction func apiButtonPressed(_ sender: Any) {
        if reachability.connection == .unavailable {
            self.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok")
        } else {
            if PurchaseManager.shared.isPremiumUser { // premium
                calculateRelativeParameters()
                calculateRatioParameters()
                presentProgressViewController()
            } else { // free
                adPopupView.show() {}
            }
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
            guard let appItemsCount = DataManager.shared.getSupportedAppsRootDataCount() else { return 0 }
            return appItemsCount
        } else {
            guard let aspectItemsCount = DataManager.shared.getSupportedAspectRootDataCount(of: selectedAppIndex) else { return 0 } // selected index
            return aspectItemsCount
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
            //not same as previous
            if selectedAppIndex != indexPath.item {
                selectedAppIndex = indexPath.item
                appCollectionView.scrollToItem(at: IndexPath(item: selectedAppIndex, section: 0), at: .centeredHorizontally, animated: true)
                
                //selected
                if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex), indexPath.item == selectedAppIndex, aspectData.count > selectedAspectIndex, selectedUniqueAspectIdentifier.lowercased() == aspectData[selectedAspectIndex].selectedImage.lowercased() {
                    
                    print("aspectData ", aspectData.count, " selectedAspectIndex ", selectedAspectIndex)
//                    self.aspectCollectionView.performBatchUpdates {
                        aspectCollectionView.reloadSections([0])
//                    } completion: { _ in
                        self.aspectCollectionView.selectItem(at: IndexPath(item: self.selectedAspectIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
//                    }
                }
                //non selected
                else {
//                    self.aspectCollectionView.performBatchUpdates {
                        self.aspectCollectionView.reloadSections([0])
//                    } completion: { _ in
                        self.aspectCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
//                    }
                }
            }
            //same as previous
            else {
                //selected
                if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex), indexPath.item == selectedAppIndex, aspectData.count > selectedAspectIndex, selectedUniqueAspectIdentifier.lowercased() == aspectData[selectedAspectIndex].selectedImage.lowercased() {
                    
                    self.aspectCollectionView.scrollToItem(at: IndexPath(item: self.selectedAspectIndex, section: 0), at: .centeredHorizontally, animated: true)
                }
                //non selected
//                else {
//                    self.aspectCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
//                }
            }
            
        }
        
        else if collectionView == aspectCollectionView {
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                selectedAspectRatio = convertRatio(ratio: aspectData[indexPath.item].ratio)
                print("selectedAspectRatio ", selectedAspectRatio ?? -1.0)
                
                selectedUniqueAspectIdentifier = aspectData[indexPath.item].selectedImage
                
                isProfileType = aspectData[indexPath.item].text.lowercased() == "profile"
                aspectData[indexPath.item].text.lowercased() == "profile" ? addMaskToCanvas() : removeMaskFromCanvas()
                
                selectedAspectIndex = indexPath.item
                aspectCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                updateUI()
            }
        }
    }
}

extension ExpandViewControllerV2: UICollectionViewDelegateFlowLayout {
    
    private func calculateAppInset() -> UIEdgeInsets {
        var cellCount: Int = 1
        var cellWidth: Double = 0.0
        var sideInset: CGFloat = 0
        
        if let appItemscount = DataManager.shared.getSupportedAppsRootDataCount() {
            cellCount = appItemscount
            for index in 0..<cellCount {
                if let appData = DataManager.shared.getSupportedAppsData(of: index) {
                    let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .medium)] // get cell label exact font
                    let cellSize = (appData.title as NSString).size(withAttributes: attributes)
                    cellWidth += cellSize.width + 32
                }
            }
            
            let emptySpace = SCREEN_WIDTH - cellWidth // no inter item spacing
            sideInset = emptySpace / 2
        }
        
        return UIEdgeInsets(top: 0, left: max(sideInset, 6), bottom: 0, right: max(sideInset, 6))
    }
    
    private func calculateAspectInset() -> UIEdgeInsets {
        var cellCount: Int = 1
        var cellWidth: Double = 0.0
        var sideInset: CGFloat = 0
        
        if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
            cellCount = aspectData.count
            for index in aspectData.indices {
                if let img = UIImage(named: aspectData[index].selectedImage) {
                    let imgAspect = (img.size.width/img.size.height)
                    cellWidth += aspectContainerView.bounds.size.height * imgAspect
                }
            }
            
            let itemInterSpacing = 12.0 * (Double(cellCount) - 1)
            let allCellWidth = cellWidth + itemInterSpacing
            let emptySpace = SCREEN_WIDTH - allCellWidth
            sideInset = emptySpace / 2
        }
        
        return UIEdgeInsets(top: 0, left: max(sideInset, 22), bottom: 0, right: max(sideInset, 22))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == appCollectionView {
            return self.calculateAppInset()
        } else {
            return self.calculateAspectInset()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if collectionView == appCollectionView {
//            return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
//        } else {
//            return UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
//        }
//        
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == appCollectionView /*,let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCell.identifier, for: indexPath) as? AppCell*/ {
            if let appData = DataManager.shared.getSupportedAppsData(of: indexPath.item) {
//                let attributes: [NSAttributedString.Key: Any] = [.font: cell.getLabelFont()]
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .medium)] // get cell label exact font
                let cellSize = (appData.title as NSString).size(withAttributes: attributes)
                return CGSize(width: cellSize.width + 32, height: collectionView.bounds.size.height)
            } else {
                return CGSize(width: 30, height: 30)
            }
        } else {
            if let aspectData = DataManager.shared.getSupportedAspectData(of: selectedAppIndex) {
                if let img = UIImage(named: aspectData[indexPath.item].selectedImage) {
                    let imgAspect = (img.size.width/img.size.height)
                    let cellSize = CGSize(width: aspectContainerView.bounds.size.height * imgAspect, height: collectionView.bounds.size.height)
                    return cellSize
                } else {
                    return CGSize(width: 30, height: 30)
                }
            } else {
                return CGSize(width: 30, height: 30)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == appCollectionView {
            return 0.0
        } else {
            return 12.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == appCollectionView {
            return 0.0
        } else {
            return 12.0
        }
    }
    
}

extension ExpandViewControllerV2: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
