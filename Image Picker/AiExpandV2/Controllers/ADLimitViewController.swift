//
//  ADLimitViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 3/6/24.
//

import UIKit

class ADLimitViewController: UIViewController {
    
    static let identifier = "ADLimitViewController"
    
    @IBOutlet private weak var limitBGView: UIView!
    @IBOutlet private weak var purchaseButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        limitBGView.layer.cornerRadius = 16
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
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
            transition.type = .reveal
            transition.subtype = .fromBottom
            
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.popViewController(animated: false)
        }
    }

    @IBAction func purchaseButtonPressed(_ sender: Any) {
        pushPurchaseViewController()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
