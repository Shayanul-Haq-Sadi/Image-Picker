//
//  ProgessViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 21/5/24.
//

import UIKit
import APNGKit
import Reachability

class ProgessViewController: UIViewController {
    
    static let identifier = "ProgessViewController"
    
    @IBOutlet private weak var canvasView: UIView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var shadowView: UIView!
    
    @IBOutlet private weak var TransparentImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var previousImageView: UIImageView!
    
    @IBOutlet private weak var canvasViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var canvasViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageContainerViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var previousImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var previousImageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var progressConainerView: UIView!
    
    @IBOutlet private weak var activityIndicatorView: APNGImageView!
    private var activityIndicatorImage: APNGImage!
    @IBOutlet private weak var processingDotLabel: UILabel!
    
    @IBOutlet private weak var purchaseContainerView: UIView!
    @IBOutlet private weak var purchaseBGView: UIImageView!
    @IBOutlet private weak var purchaseButton: UIButton!
    
    @IBOutlet private weak var cancelButton: UIButton!
    
    var pickedImage: UIImage!
    var downloadedImage: UIImage!
    var imageData: Data!
    
    var topRatio: CGFloat!
    var bottomRatio: CGFloat!
    var leftRatio: CGFloat!
    var rightRatio: CGFloat!
    var keepOriginalSize = "False"
//    var keepOriginalSize = "True"
    
    var selectedAspectRatio: CGFloat!
    var relativeScaleFactor: CGFloat!
    
    var isFromExapand: Bool = false
    var isFromDownload: Bool = false
    
    private var isAdShown: Bool = false
    private var isAPICalled: Bool = false
    private var isPurchasePressed: Bool = false
    private var isDownloaded: Bool = false
    private var isAdFinished: Bool = false
    private var isSetupDone: Bool = false
    
    private var processingTimer: Timer?
    private var dotCount = 0
    
    var isProfileType: Bool = false
        
    private var timer: Timer!
    
    var downloadCompletion: (( _ pickedImage: UIImage, _ downloadedImage: UIImage ) -> Void)? = nil
    
    //declare this property where it won't go out of scope relative to your listener
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicatorView()
        adNewLogic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
        activityIndicatorView.startAnimating()
        startProcessingAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        activityIndicatorView.stopAnimating()
        stopProcessingAnimation()
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
        
        if isFromExapand {
            UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut) {
                self.canvasViewTopConstraint.constant = 10 + 44 // for nav visibility
                self.canvasViewBottomConstraint.constant = 117
                self.view.layoutIfNeeded()
                
                self.previousImageViewLeadingConstraint.constant = self.leftRatio * self.imageView.frame.width * self.relativeScaleFactor
                self.previousImageViewTrailingConstraint.constant = self.rightRatio * self.imageView.frame.width * self.relativeScaleFactor
                self.previousImageViewTopConstraint.constant = self.topRatio * self.imageView.frame.height * self.relativeScaleFactor
                self.previousImageViewBottomConstraint.constant = self.bottomRatio * self.imageView.frame.height * self.relativeScaleFactor
                self.view.layoutIfNeeded()
            }
        }
        
        if self.isProfileType {
            self.addMaskToCanvas(animated: true)
        } else {
            self.removeMaskFromCanvas(animated: true)
        }
    }
    
    private func setupUI() {
        
        if isFromExapand {
            self.canvasViewTopConstraint.constant = 10
            self.canvasViewBottomConstraint.constant = 249.2
            self.view.layoutIfNeeded()
        }
        
        if isFromDownload {
            self.canvasViewTopConstraint.constant = 10 + 44 // for nav visibility
            self.canvasViewBottomConstraint.constant = 117
            self.view.layoutIfNeeded()
        }
        
        imageView.image = pickedImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageContainerViewAspectRatioConstraint = self.imageContainerViewAspectRatioConstraint.changeMultiplier(multiplier: (selectedAspectRatio) )
        self.imageViewAspectRatioConstraint = self.imageViewAspectRatioConstraint.changeMultiplier(multiplier: (pickedImage.size.width/pickedImage.size.height) )
        self.view.layoutIfNeeded()
        
        previousImageView.image = pickedImage
        
        previousImageViewLeadingConstraint.constant = leftRatio * imageView.frame.width * relativeScaleFactor
        previousImageViewTrailingConstraint.constant = rightRatio * imageView.frame.width * relativeScaleFactor
        previousImageViewTopConstraint.constant = topRatio * imageView.frame.height * relativeScaleFactor
        previousImageViewBottomConstraint.constant = bottomRatio * imageView.frame.height * relativeScaleFactor
        self.view.layoutIfNeeded()
        
        purchaseContainerView.clipsToBounds = true
        purchaseContainerView.layer.cornerRadius = 16
        purchaseBGView.layer.cornerRadius = 16
        
        cancelButton.layer.cornerRadius = 20
        
    }
    
    private func addActivityIndicatorView() {
        do {
            if let url = Bundle.main.url(forResource: "Loading 1", withExtension: "png") {
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
    
    private func startProcessingAnimation() {
        processingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateprocessingDotLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateprocessingDotLabel() {
        dotCount = (dotCount + 1) % 4
        switch dotCount {
        case 0:
            processingDotLabel.text = "."
        case 1:
            processingDotLabel.text = ".."
        case 2:
            processingDotLabel.text = "..."
        default:
            processingDotLabel.text = ""
        }
    }
    
    func stopProcessingAnimation() {
        processingTimer?.invalidate()
        processingTimer = nil
    }

    private func addMaskToCanvas(animated: Bool = false) {
        let maskPath = UIBezierPath(ovalIn: CGRect(x: 0, y: (canvasView.bounds.height - canvasView.bounds.width)/2 , width: canvasView.bounds.width, height: canvasView.bounds.width))
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = maskPath.cgPath
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 1, options: .curveEaseInOut) {
                self.canvasView.layer.mask = maskLayer
            }
        } else {
            self.canvasView.layer.mask = maskLayer
        }
    }
    
    private func removeMaskFromCanvas(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.canvasView.layer.mask = nil
            }
        } else {
            self.canvasView.layer.mask = nil
        }
    }
    
    private func adNewLogic() {
        if PurchaseManager.shared.isPremiumUser { // no ad direct flow
            //no show off boost
            purchaseContainerView.isHidden = true
            
            // api call
            self.uploadImage { [weak self] picked, downloaded, error in
                
                if let picked, let downloaded {
                    // send to previous nav stack
                    self?.downloadCompletion?(picked, downloaded)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.dismiss(animated: true)
                    }
                } else if error != nil {
                    // error handle
                    if self?.reachability.connection == .unavailable {
                        self?.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok") {
                            self?.dismiss(animated: true)
                        }
                    } else {
                        self?.showAlert(title: "Oops!", message: "Something went wrong! Please try again later", cancelButtonTitle: "Ok") {
                            self?.dismiss(animated: true)
                        }
                    }
                }
            }
        }
        else if !PurchaseManager.shared.isPremiumUser { //ad flow        
            if !self.isAdShown { //ad not shown so show add
                
                if !isAPICalled {
                    self.uploadImage { picked, downloaded, error in
                        
                        if let picked, let downloaded {
                            if self.isAdFinished && self.isDownloaded {
                                // send to previous nav stack
                                self.downloadCompletion?(picked, downloaded)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.dismiss(animated: true)
                                }
                            }
                        } else if let error {
                            // error handle
                            // maybe ad visible so it will be under
                            // maybe purchase visible so it will be under
                            if self.isAdShown { // ad visible case
                                // dismiss ad first then show error on progress vc
                                self.dismiss(animated: true) {
                                    if self.reachability.connection == .unavailable {
                                        self.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok") {
                                            self.dismiss(animated: true)
                                        }
                                    } else {
                                        self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later", cancelButtonTitle: "Ok") {
                                            self.dismiss(animated: true)
                                        }
                                    }
                                }
                            } else if self.isPurchasePressed { // purchase visible case

                            } else { // ad and purchase not visible case
                                // directly show error on progress vc
                                if self.reachability.connection == .unavailable {
                                    self.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok") {
                                        self.dismiss(animated: true)
                                    }
                                } else {
                                    self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later", cancelButtonTitle: "Ok") {
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                if !self.isPurchasePressed {
                    print("timer added")
                    timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                        
                        self.presentAdViewController { done in
                            if done {
                                if self.isAdFinished && self.isDownloaded {
                                    // send to previous nav stack
                                    self.downloadCompletion?(self.pickedImage, self.downloadedImage)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.presentAdViewController { done in
                        if done {
                            if self.isAdFinished && self.isDownloaded {
                                // send to previous nav stack
                                self.downloadCompletion?(self.pickedImage, self.downloadedImage)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
                
            }
            else if self.isAdShown { // add shown alraedy so normal flow
                
            }
        }
    }
    
    private func uploadImage(completion: @escaping (_ pickedImage: UIImage?, _ downloadedImage: UIImage?, _ error: Error?) -> Void) {
        print("uploadImage API CALLED")
        isAPICalled = true
        APIManager.shared.uploadImage(imageData: imageData, leftPercentage: leftRatio, rightPercentage: rightRatio, topPercentage: topRatio, bottomPercentage: bottomRatio, keepOriginalSize: keepOriginalSize){ response in
            switch response {
            case .success(let data):
                print("download successful.")
                if let image = UIImage(data: data) {
                    
                    self.downloadedImage = image
                    self.isDownloaded = true
                    completion(self.pickedImage, self.downloadedImage, nil)
                    
                } else {
                    print("Failed to convert data to image")
                    self.showAlert(title: "Oops!", message: "Something went wrong! Please try again later", cancelButtonTitle: "Ok") {
                        self.dismiss(animated: true)
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(nil, nil, error)
            }
        }
    }
    
    private func presentAdViewController(completion: @escaping (_ done: Bool) -> Void) {
        guard let VC = UIStoryboard(name: "AiExpandV2", bundle: nil).instantiateViewController(withIdentifier: ADViewController.identifier) as? ADViewController else { return }
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
        guard let VC = UIStoryboard(name: "AiExpandV2", bundle: nil).instantiateViewController(withIdentifier: PurchaseViewController.identifier) as? PurchaseViewController else { return }
        
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
            if PurchaseManager.shared.isPremiumUser {
                APIManager.shared.cancelOngoingRequests()
            }
            
            self.adNewLogic()
            
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
