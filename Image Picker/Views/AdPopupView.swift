//
//  AdPopupView.swift
//  Image Picker
//
//  Created by BCL Device-18 on 15/7/24.
//

import UIKit

class AdPopupView: UIView {
    
    @IBOutlet private weak var popupViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var popupView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    
    @IBOutlet private weak var purchaseButton: UIButton!
    @IBOutlet private weak var adButton: UIButton!
    
    var closePressed: (() -> Void)? = nil
    var purchasePressed: (() -> Void)? = nil
    var adPressed: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.layer.cornerRadius = 20
        popupView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.isHidden = true
        popupViewBottomConstraint.constant = -334
    }
    
    func show(delay: Double = 0.0, completion: @escaping () -> Void?) {
        self.isHidden = false
        UIView.animate(withDuration: 0.35, delay: delay, options: .curveEaseInOut) {
            self.popupViewBottomConstraint.constant = 0
            self.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }
    
    func hide(delay: Double = 0.0, completion: @escaping () -> Void?) {
        UIView.animate(withDuration: 0.35, delay: delay, options: .curveEaseInOut) {
            self.popupViewBottomConstraint.constant = -334
            self.layoutIfNeeded()
        } completion: { _ in
            self.isHidden = true
            completion()
        }
    }
    
    @IBAction private func closeButtonPressed(_ sender: Any) {
        self.closePressed?()
    }
    
    @IBAction private func purchaseButtonPressed(_ sender: Any) {
        self.purchasePressed?()
    }
    
    @IBAction private func adButtonPressed(_ sender: Any) {
        self.adPressed?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        if !popupView.frame.contains(location) {
            print("Tapped outside the popupView")
            hide() {}
        }
    }
    

}
