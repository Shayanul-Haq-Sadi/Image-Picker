//
//  UIViewController+Extensions.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/5/24.
//

import UIKit


extension UIViewController {
    
    public func showAlert(title: String, message: String, defaultButtonTitle: String? = nil, /*destructiveButtonTitle: String? = nil,*/ cancelButtonTitle: String? = nil){
        var hasButtons = false
        let alertMessagePopUpBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let defaultButtonTitle {
            let actionButton = UIAlertAction(title: defaultButtonTitle, style: .default) { _ in
                self.dismiss(animated: true)
            }
            alertMessagePopUpBox.addAction(actionButton)
            hasButtons = true
        }
        
        if let cancelButtonTitle {
            let actionButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
            alertMessagePopUpBox.addAction(actionButton)
            hasButtons = true
        }
        
        self.present(alertMessagePopUpBox, animated: true)
        
        if !hasButtons {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(animated: true)
            }
        }
    }
    
    public func showAlert(title: String, message: String, cancelButtonTitle: String, completion: @escaping () -> Void) {
        let alertMessagePopUpBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionButton = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            print("\(cancelButtonTitle) Pressed")
            completion()
        }
        
        alertMessagePopUpBox.addAction(actionButton)
        self.present(alertMessagePopUpBox, animated: true) 
    }
    
    public func showAlert(title: String, message: String, defaultButtonTitle: String, cancelButtonTitle: String, completion: @escaping (UIAlertAction.Style) -> Void) {
        let alertMessagePopUpBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionButton1 = UIAlertAction(title: defaultButtonTitle, style: .default) { action in
            print("\(defaultButtonTitle) Pressed")
            completion(action.style)
        }
        
        let actionButton2 = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            print("\(cancelButtonTitle) Pressed")
            completion(action.style)
        }
        
        alertMessagePopUpBox.addAction(actionButton1)
        alertMessagePopUpBox.addAction(actionButton2)
        self.present(alertMessagePopUpBox, animated:true)
    }
}
