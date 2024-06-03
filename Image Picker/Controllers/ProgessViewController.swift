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
    
    private var isPremiumUser: Bool = false //
    private var isAdShown: Bool = false //
    private var isPurchasePressed: Bool = false
    private var isDownloaded: Bool = false
    private var isAdFinished: Bool = false
    
    private var timer: Timer!
    
    var downloadCompletion: (( _ pickedImage: UIImage, _ downloadedImage: UIImage ) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addActivityIndicatorView()
        activityIndicatorView.startAnimating()
                
        print("timer added")
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
            self.adLogic()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    private func adLogic() {
        if isPremiumUser { // no ad direct flow
            //no show off boost
            purchaseContainerView.isHidden = true
            
            // api call
            self.uploadImage { [weak self] picked, downloaded in
                
                // send to previous nav stack
                self?.downloadCompletion?(picked, downloaded)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.dismiss(animated: true)
                }
            }
        }
        else if !isPremiumUser { //ad flow
            if !self.isAdShown { //ad not shown so show add
                self.presentAdViewController { done in
                    if !done {
                        // api call
                        self.uploadImage { picked, downloaded in
                            // send to previous nav stack
                            self.downloadCompletion?(picked, downloaded)
                            
                            if self.isAdFinished && self.isDownloaded {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    } else {
                        if self.isAdFinished && self.isDownloaded {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
            else if self.isAdShown { // add shown alraedy so normal flow
                
            }
        }
    }
    
    private func uploadImage(completion: @escaping ( _ pickedImage: UIImage, _ downloadedImage: UIImage) -> Void) {
        print("uploadImage API CALLED")
        APIManager.shared.uploadImage(imageData: imageData, leftPercentage: leftRatio, rightPercentage: rightRatio, topPercentage: topRatio, bottomPercentage: bottomRatio, keepOriginalSize: keepOriginalSize){ response in
            switch response {
            case .success(let data):
                print("download successful.")
                if let image = UIImage(data: data) {
                    
                    self.downloadedImage = image
                    self.isDownloaded = true
                    completion(self.pickedImage, self.downloadedImage)
                    
                } else {
                    print("Failed to convert data to image")
                    self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func presentAdViewController(completion: @escaping (_ done: Bool) -> Void) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ADViewController.identifier) as? ADViewController else { return }
        self.isAdShown = true
        
        VC.modalTransitionStyle = .coverVertical
        VC.modalPresentationStyle = .fullScreen
        
        completion(false)
        present(VC, animated: true)
        
        VC.closeCompletion = {
            self.dismiss(animated: true)
            self.isAdFinished = true
            self.purchaseContainerView.isHidden = true
            completion(true)
        }
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
            if self.isPurchasePressed {
                self.adLogic()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let transition = CATransition()
                transition.duration = 0.4
                transition.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
                transition.type = .reveal
                transition.subtype = .fromBottom
                
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    @IBAction func purchaseButtonPressed(_ sender: Any) {
        isPurchasePressed = true
        timer.invalidate()
        print("timer invalidate")
        pushPurchaseViewController()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        APIManager.shared.cancelOngoingRequests()
        dismiss(animated: true)
    }
}
