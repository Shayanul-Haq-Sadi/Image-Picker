//
//  DownloadViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 23/5/24.
//

import UIKit
import Photos

class DownloadViewController: UIViewController, UIGestureRecognizerDelegate {
    
    static let identifier = "DownloadViewController"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var TransparentImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var compareView: UIView!
    @IBOutlet private weak var compareImage: UIImageView!
    
    @IBOutlet private weak var editorContainerView: UIView!
    @IBOutlet private weak var regenerateButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    
    @IBOutlet private weak var saveContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var saveContainerView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var editorButton: UIButton!
    
    var pickedImage: UIImage! //= UIImage(named: "Golden Statue_cartoon")
    var downloadedImage: UIImage! //= UIImage(named: "GTA_cartoon")
    var renderedImage: UIImage! //= UIImage(named: "GTA_cartoon")
    
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    var selectedAspectRatio: CGFloat!
    
    private var isSaveContainerShowing: Bool = false
    private var lastSavedAssetIdentifier = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGesture()
        renderImage()
        
//        saveImageToPhotoLibrary(downloadedImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (self.downloadedImage.size.width/self.downloadedImage.size.height))
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.imageView.contentMode = .scaleAspectFit
        }

    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.image = downloadedImage
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        compareImage.isUserInteractionEnabled = true
        
        saveContainerView.translatesAutoresizingMaskIntoConstraints = false
        saveContainerViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (selectedAspectRatio) )
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
    }
    
    private func addGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressImage(_:)))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0
        compareImage.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func longPressImage(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .began:
            UIView.transition(with: self.imageView, duration: 0.8, options: [.transitionCrossDissolve],  animations: {
                    self.imageView.image = self.pickedImage
                })
            
            case .ended:
            UIView.transition(with: self.imageView, duration: 0.8, options: [.transitionCrossDissolve],  animations: {
                    self.imageView.image = self.downloadedImage
                })
            
            default: break
        }
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
                if (PHAsset.fetchAssets(withLocalIdentifiers: [self.lastSavedAssetIdentifier], options: nil).count > 0) {
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
                        self.lastSavedAssetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier ?? ""
                    } completionHandler: { success, error in
                        if success {
                            print("Successfully saved image to photo library")
                            DispatchQueue.main.async {
                                self.showAlert(title: "Saved!", message: "Successfully saved your creation to camera roll")
                            }
                        } else if let error = error {
                            print("Error saving image: \(error.localizedDescription)")
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
    
    private func presentADLimitViewController() {
        guard let navVC = storyboard?.instantiateViewController(identifier: "ADLimitNAVController") as?  UINavigationController else { return }
        
        navVC.modalPresentationStyle = .overCurrentContext
        navVC.modalTransitionStyle = .crossDissolve
        
        if let VC = navVC.topViewController as? ADLimitViewController {
            VC.navigationController?.navigationBar.isHidden = true
        }
        
        present(navVC, animated: true)
    }

    @IBAction func regenerateButtonPressed(_ sender: Any) {
        if PurchaseManager.shared.isPremiumUser {
            lastSavedAssetIdentifier = ""
            
            imageView.contentMode = .scaleAspectFill
            imageView.image = downloadedImage
            
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
            self.view.layoutIfNeeded()
            
            presentProgressViewController()
            
        } else {
            if ADManager.shared.isAdLimitReached {
                presentADLimitViewController()
            } else {
                lastSavedAssetIdentifier = ""
                
                imageView.contentMode = .scaleAspectFill
                imageView.image = downloadedImage
                
                self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
                self.view.layoutIfNeeded()
                
                presentProgressViewController()
            }
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        // move view from down to uo for save
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.saveContainerViewHeightConstraint.constant = 110
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.isSaveContainerShowing = true
            self.compareImage.isHidden = true
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
//        saveUniqueImageToPhotos(image: downloadedImage)
        saveUniqueImageToPhotos(image: renderedImage)
    }
    
    @IBAction func editorButtonPressed(_ sender: Any) {
        pushEditViewController()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if isSaveContainerShowing {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                self.saveContainerViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.isSaveContainerShowing = false
                self.compareImage.isHidden = false
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        let touch = touches.first
        guard let location = touch?.location(in: self.saveContainerView) else { return }
        if !saveContainerView.frame.contains(location) && isSaveContainerShowing {
            print("Tapped outside the saveContainerView")
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                self.saveContainerViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.isSaveContainerShowing = false
                self.compareImage.isHidden = false
            }
        }
    }
    
    
}
