//
//  ImageViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 19/5/24.
//

import UIKit
import APNGKit

class ImageViewController: UIViewController {
    
    static let identifier = "ImageViewController"
    
    @IBOutlet weak var apiButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var availableContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicatorView: APNGImageView!
    private var activityIndicatorImage: APNGImage!
    
    @IBOutlet weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var aspectButton1: UIButton!
    @IBOutlet weak var aspectButton2: UIButton!
    @IBOutlet weak var aspectButton3: UIButton!
    @IBOutlet weak var aspectButton4: UIButton!
    
    var pickedImage: UIImage!
    
    var downloadedImage: UIImage! {
        didSet{
            apiButton.isUserInteractionEnabled = false
            saveButton.isUserInteractionEnabled = true
            isAspectChanged = false
            isImageSaved = false
        }
    }
    
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    var isImageSaved: Bool = false
    var isImageDownloaded: Bool = false
    var isAspectChanged: Bool = false {
        didSet {
            if isAspectChanged {
                apiButton.isUserInteractionEnabled = true
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addActivityIndicatorView()
    }
    
    private func setupUI() {
        apiButton.isUserInteractionEnabled = false
        saveButton.isUserInteractionEnabled = false
        
        activityIndicatorView.isHidden = true
        activityIndicatorView.layer.cornerRadius = 30
        
        imageView.image = pickedImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
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
    
    private func addActivityIndicatorView() {
        do {
            if let url = Bundle.main.url(forResource: "infinteLoader", withExtension: "png") {
                activityIndicatorImage = try APNGImage(fileURL: url, decodingOptions: .fullFirstPass)
                activityIndicatorView.autoStartAnimationWhenSetImage = false
                activityIndicatorView.image = activityIndicatorImage
            }
        } catch {
            if let normalImage = error.apngError?.normalImage {
                activityIndicatorView.staticImage = normalImage
            } else {
                print("Error: \(error)")
            }
        }

//        activityIndicatorView.onOnePlayDone.delegate(on: self) { (self, count) in
//            print("Played: \(count)")
//        }
    }
    
    
    private func uploadImage(imageData: Data) {
        //calculate
        calculateRatioParameters()
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        print("uploadImage API CALLED")
        APIManager.shared.uploadImage(imageData: imageData, leftPercentage: leftRatio, rightPercentage: rightRatio, topPercentage: topRatio, bottomPercentage: bottomRatio, keepOriginalSize: keepOriginalSize){ resonse in
            switch resonse {
            case .success(let data):
                print("download successful.")
                if let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                    
                    self.isImageDownloaded = true
                    self.downloadedImage = image
//                    self.imageView.image = image
                    UIView.transition(with: self.imageView, duration: 2.0, options: .transitionCrossDissolve, animations: {
                        self.imageView.image = image
                    }) { _ in
                    }
                    
                    self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (image.size.width/image.size.height) )
                    
                    self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (image.size.width/image.size.height) )
                    self.view.layoutIfNeeded()
                    
                } else {
                    print("Failed to convert data to image")
                    self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Image saved to photo library")
        isImageSaved = true
    }
    
    @IBAction func apiButtonPressed(_ sender: Any) {
        uploadImage(imageData: self.imageData)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if isImageSaved {
            showAlert(title: "Already Saved!", message: "Photo already saved")
        } else {
            saveImageToPhotoLibrary(downloadedImage)
            showAlert(title: "Saved!", message: "Successfully saved your creation to camera roll")
        }
    }
    
    @IBAction func aspectButton1pressed(_ sender: Any) {
        if isImageDownloaded {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (16/9))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (downloadedImage.size.width/downloadedImage.size.height))
        } else {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (16/9))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height))
        }
        
        self.view.layoutIfNeeded()
        isAspectChanged = true
    }
    
    @IBAction func aspectButton2pressed(_ sender: Any) {
        if isImageDownloaded {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (9/16))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (downloadedImage.size.width/downloadedImage.size.height))
        } else {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (9/16))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height))
        }
        
        self.view.layoutIfNeeded()
        isAspectChanged = true
    }
    
    @IBAction func aspectButton3pressed(_ sender: Any) {
        if isImageDownloaded {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (1/1))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (downloadedImage.size.width/downloadedImage.size.height))
        } else {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (1/1))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height))
        }
        
        self.view.layoutIfNeeded()
        isAspectChanged = true
    }
    
    @IBAction func aspectButton4Pressed(_ sender: Any) {
        if isImageDownloaded {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (downloadedImage.size.width/downloadedImage.size.height))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (downloadedImage.size.width/downloadedImage.size.height))
        } else {
            self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height))
            self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height))
        }
        
        self.view.layoutIfNeeded()
        isAspectChanged = true
    }
}
