//
//  DownloadViewControllerV2.swift
//  Image Picker
//
//  Created by BCL Device-18 on 6/6/24.
//

import UIKit
import Photos
import Reachability

class DownloadViewControllerV2: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    static let identifier = "DownloadViewControllerV2"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    
    @IBOutlet private weak var TransparentImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var previousImageView: UIImageView!

    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var previousImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousImageViewBottomConstraint: NSLayoutConstraint!
    
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
    
    var selectedAspectRatio: CGFloat! = 1.0
    var relativeScaleFactor: CGFloat!
    
    private var selectedIndex: Int = 0
    
    private var lastSavedAssetIdentifiers: [String] = []
    
    private var isSetupDone: Bool = false
    
    var isProfileType: Bool = false
    
    //declare this property where it won't go out of scope relative to your listener
    let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
        addGesture()
        loadCollectionView()
        configAdPopup()
        configAdLimitPopup()
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
//        need to remove temp on vc close
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
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
        collectionView.frame = downloadContainerView.bounds
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if !isSetupDone {
            setupUI() // bool check for the first timer
            isSetupDone = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.35, delay: 0, options: [.transitionCrossDissolve]) {
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.selectedAspectRatio))
            self.view.layoutIfNeeded()
            
            self.testimageView.frame = self.imageView.bounds
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.imageView.contentMode = .scaleAspectFit
            self.previousImageView.alpha = 0
            
            self.testimageView.isHidden = true
            self.imageView.isHidden = false
        }

    }
    
    private var testimageView: UIImageView! = UIImageView()
    
    private func setupUI() {
        testimageView.isHidden = false
        testimageView.image = downloadedImage
        testimageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(testimageView)
        testimageView.center = imageView.center
        
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = downloadedImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        compareImage.isUserInteractionEnabled = true
        
        bgView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.06).cgColor
        bgView.layer.borderWidth = 1
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (selectedAspectRatio) )
        self.view.layoutIfNeeded()
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
        previousImageView.image = pickedImage
        
        previousImageViewLeadingConstraint.constant = leftRatio * imageView.frame.width * relativeScaleFactor
        previousImageViewTrailingConstraint.constant = rightRatio * imageView.frame.width * relativeScaleFactor
        previousImageViewTopConstraint.constant = topRatio * imageView.frame.height * relativeScaleFactor
        previousImageViewBottomConstraint.constant = bottomRatio * imageView.frame.height * relativeScaleFactor
        self.view.layoutIfNeeded()
        
        imageView.layer.cornerRadius = isProfileType ? (canvasView.frame.width/2) : 0
        testimageView.frame = previousImageView.bounds
    }
    
    private func addGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressImageV3(_:)))
        longPressGesture.delegate = self
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.minimumPressDuration = 0.0
        imageView.addGestureRecognizer(longPressGesture)
        
        let longPressGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(longPressImageV3(_:)))
        longPressGesture1.delegate = self
        longPressGesture1.numberOfTouchesRequired = 1
        longPressGesture1.minimumPressDuration = 0.0
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
        collectionView.backgroundColor = UIColor(red: 0.09, green: 0.1, blue: 0.11, alpha: 1)
        
        downloadContainerView.addSubview(collectionView)
        collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: true, scrollPosition: .left)
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
            if ADManager.shared.isAdLimitReached {
                self.adLimitView.show() {}
            } else {
                self.adPopupView.hide {
                                        
                    self.previousImageView.alpha = 1
                    self.testimageView.frame = self.previousImageView.bounds
                    self.testimageView.isHidden = false
                    self.imageView.isHidden = true
                    self.imageView.contentMode = .scaleAspectFill
                    self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.pickedImage.size.width/self.pickedImage.size.height) )
                    self.view.layoutIfNeeded()
                    
                    self.presentProgressViewController()
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
    
    private func calculateInset(cellCount: Int) -> UIEdgeInsets {
        let cellWidth = 76 * cellCount
        let itemInterSpacing = 12 * (cellCount - 1)
        let allCellWidth = cellWidth + itemInterSpacing
        let emptySpace = SCREEN_WIDTH - CGFloat(allCellWidth)
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
        var expectedWidth: CGFloat
        var expectedHeight: CGFloat
        
        let calculatedWidth = (pickedImage.size.width + (pickedImage.size.width * (leftRatio + rightRatio)))
        let calculatedHeight = (pickedImage.size.height + (pickedImage.size.height * (topRatio + bottomRatio)))
        
        // only the minimum goes ahead
        if calculatedWidth < calculatedHeight {
            // width small
            expectedWidth = calculatedWidth
            expectedHeight = expectedWidth * (1 / selectedAspectRatio)
        } else if calculatedWidth > calculatedHeight {
            // height small
            expectedHeight = calculatedHeight
            expectedWidth = expectedHeight * selectedAspectRatio
        } else {
            // equal
            expectedWidth = calculatedWidth
            expectedHeight = calculatedHeight
        }
        
        if isProfileType {
            let profileParentLayer = CALayer()
            profileParentLayer.frame = CGRect(x: 0, y: 0, width: expectedWidth, height: expectedHeight)
            profileParentLayer.backgroundColor = UIColor.black.cgColor
            
            let profileLayer = CALayer()
            profileLayer.frame = CGRect(x: 0, y: 0, width: expectedWidth, height: expectedHeight)
            profileLayer.position = CGPoint(x: expectedWidth/2, y: expectedHeight/2)
            profileLayer.contents = image.cgImage
            profileLayer.cornerRadius = expectedWidth/2
            profileLayer.masksToBounds  = true
            profileParentLayer.addSublayer(profileLayer)
            
            if let renderedImage = image.renderImageFromLayer(profileParentLayer) {
                return renderedImage
            } else {
                return nil
            }
        }
        else {
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
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Image saved to photo library")
    }
           
    private func saveUniqueImageToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                print("Photo library access not authorized")
                DispatchQueue.main.async {
                    self.showAlert(title: "Warning!", message: "NoCrop wants to accesss your Photos permission to save edited Photo", defaultButtonTitle: "Go to Settings", cancelButtonTitle: "Cancel") { style in
                        if style == .default {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        } else if style == .cancel {
                            // dismiss
                        }
                    }
                }
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
            VC.relativeScaleFactor = relativeScaleFactor
            VC.isFromDownload = true
            
            VC.isProfileType = isProfileType
            
            VC.downloadCompletion = { picked, downloaded in
                self.downloadedImage = downloaded
                self.imageView.image = self.downloadedImage
                self.cellCount += 1
                self.selectedIndex = self.downloadedImageArray.count - 1
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
    
    private func presentExpandViewControllerV2(pickedImage: UIImage, imageData: Data) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ExpandViewControllerV2.identifier) as? ExpandViewControllerV2 else { return }

        VC.pickedImage = pickedImage
        VC.imageData = imageData
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    private func regenerateImageV3() {
        if PurchaseManager.shared.isPremiumUser {
            
            previousImageView.alpha = 1
            testimageView.frame = previousImageView.bounds
            testimageView.isHidden = false
            imageView.isHidden = true
            imageView.contentMode = .scaleAspectFill
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
            self.view.layoutIfNeeded()
            
            presentProgressViewController()
        } else {
            adPopupView.show() {}
        }
    }
    
    @objc private func longPressImageV3(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .began:
                self.previousImageView.alpha = 1
                self.imageView.alpha = 0
                
            case .ended:
                self.imageView.alpha = 1
                self.previousImageView.alpha = 0
                
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
            if self.reachability.connection == .unavailable {
                self.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok")
            } else {
                regenerateImageV3()
            }
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
