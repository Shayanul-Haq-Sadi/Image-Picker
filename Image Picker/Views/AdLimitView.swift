//
//  AdLimitView.swift
//  Image Picker
//
//  Created by BCL Device-18 on 28/7/24.
//

import UIKit

class AdLimitView: UIView {
    
    @IBOutlet private weak var limitBGView: UIView!
    @IBOutlet private weak var purchaseButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    var purchasePressed: (() -> Void)? = nil
    var closePressed: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        limitBGView.layer.cornerRadius = 16
        self.isHidden = true
        self.alpha = 0
    }
    
    func show(delay: Double = 0.0, completion: @escaping () -> Void?) {
        self.isHidden = false
        UIView.animate(withDuration: 0.35, delay: delay, options: .curveEaseInOut) {
            self.alpha = 1
        } completion: { _ in
            completion()
        }
    }
    
    func hide(delay: Double = 0.0, completion: @escaping () -> Void?) {
        UIView.animate(withDuration: 0.35, delay: delay, options: .curveEaseInOut) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
            completion()
        }
    }
    
    @IBAction private func purchaseButtonPressed(_ sender: Any) {
        self.purchasePressed?()
    }
    
    @IBAction private func closeButtonPressed(_ sender: Any) {
        self.closePressed?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        if !limitBGView.frame.contains(location) {
            print("Tapped outside the limitBGView")
            hide() {}
        }
    }
    
}
