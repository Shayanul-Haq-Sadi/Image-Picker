//
//  PurchaseManager.swift
//  Image Picker
//
//  Created by BCL Device-18 on 4/6/24.
//

import UIKit

class PurchaseManager {
    
    static let shared = PurchaseManager()
    
    var isPremiumUser: Bool = false
    
    private var isPurchased: Bool = false {
        didSet {
            isPremiumUser = isPurchased
            print("isPremiumUser ", isPremiumUser)
        }
    }
    
    func buy() {
        isPurchased = true
    }
    
    func restore() {
        isPurchased = false
    }
}


