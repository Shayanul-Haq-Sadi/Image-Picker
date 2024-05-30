//
//  ProgessViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 21/5/24.
//

import UIKit
import APNGKit

class ProgessViewController: UIViewController {
    
    static let identifier = "ProgessViewController"
    
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var TransparentImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var progressConainerView: UIView!
    
    @IBOutlet weak var activityIndicatorView: APNGImageView!
    private var activityIndicatorImage: APNGImage!
    
    @IBOutlet weak var purchaseContainerView: UIView!
    @IBOutlet weak var purchaseBGView: UIImageView!
    @IBOutlet weak var purchaseButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var pickedImage: UIImage!
    
    var downloadedImage: UIImage!
    
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
    
    var selectedAspectRatio: CGFloat!
    
    
    var downloadCompletion: (( _ pickedImage: UIImage, _ downloadedImage: UIImage ) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addActivityIndicatorView()
        activityIndicatorView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // apicall
        uploadImage()
    }
    
    private func setupUI() {
        
        imageView.image = pickedImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (selectedAspectRatio) )
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
        purchaseContainerView.clipsToBounds = true
        purchaseContainerView.layer.cornerRadius = 16
        purchaseBGView.layer.cornerRadius = 16
        purchaseButton.layer.cornerRadius = 12
        
        cancelButton.layer.cornerRadius = 20
        
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
    
    private func uploadImage() {
        print("uploadImage API CALLED")
        APIManager.shared.uploadImage(imageData: imageData, leftPercentage: leftRatio, rightPercentage: rightRatio, topPercentage: topRatio, bottomPercentage: bottomRatio, keepOriginalSize: keepOriginalSize){ response in
            switch response {
            case .success(let data):
                print("download successful.")
                if let image = UIImage(data: data) {
                    
                    self.downloadedImage = image
                    
                    // send to previous nav stack
                    self.downloadCompletion?(self.pickedImage, self.downloadedImage)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true)
                    }
                    
                } else {
                    print("Failed to convert data to image")
                    self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @IBAction func purchaseButtonPressed(_ sender: Any) {
//        self.navigationController?.pushViewController(UIViewController(), animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        APIManager.shared.cancelOngoingRequests()
        dismiss(animated: true)
    }
}
