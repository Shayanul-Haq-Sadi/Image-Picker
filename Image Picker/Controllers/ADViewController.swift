//
//  ADViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 30/5/24.
//

import UIKit

class ADViewController: UIViewController {
    
    static let identifier = "ADViewController"

    @IBOutlet weak var closeButton: UIButton!
    
    var closeCompletion: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        ADManager.shared.adLoaded()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.closeButton.isHidden = false
            print("AD finished")
        }
    }
    
    private func setupUI() {
        closeButton.isHidden = true
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        closeCompletion?()
    }
}
