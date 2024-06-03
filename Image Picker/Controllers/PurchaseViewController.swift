//
//  PurchaseViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 2/6/24.
//

import UIKit

class PurchaseViewController: UIViewController {
    
    static let identifier = "PurchaseViewController"

    @IBOutlet weak var closeButton: UIButton!
    
    var closeCompletion: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {     
        closeCompletion?()
    }
    
}
