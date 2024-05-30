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
    
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var TransparentImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var compareView: UIView!
    @IBOutlet weak var compareImage: UIImageView!
    
    @IBOutlet weak var editorContainerView: UIView!
    @IBOutlet weak var regenerateButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var saveContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveContainerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editorButton: UIButton!
    
    var pickedImage: UIImage! //= UIImage(named: "Golden Statue_cartoon")
    var downloadedImage: UIImage! //= UIImage(named: "GTA_cartoon")
    
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    var selectedAspectRatio: CGFloat!
    
    var isSaveContainerShowing: Bool = false
    var lastSavedAssetIdentifier = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGesture()
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
            UIView.transition(with: self.imageView, duration: 0.5, options: [.curveEaseInOut, .transitionCrossDissolve],  animations: {
                    self.imageView.image = self.pickedImage
                })
            
            case .ended:
            UIView.transition(with: self.imageView, duration: 0.5, options: [.curveEaseInOut, .transitionCrossDissolve],  animations: {
                    self.imageView.image = self.downloadedImage
                })
            
            default: break
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
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ProgessViewController.identifier) as? ProgessViewController else { return }
     
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
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        present(VC, animated: true)
    }
    

    @IBAction func regenerateButtonPressed(_ sender: Any) {
        lastSavedAssetIdentifier = ""
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = downloadedImage
        
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
        presentProgressViewController()
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
        saveUniqueImageToPhotos(image: downloadedImage)
    }
    
    @IBAction func editorButtonPressed(_ sender: Any) {
        
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
