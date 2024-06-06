//
//  ADManager.swift
//  Image Picker
//
//  Created by BCL Device-18 on 3/6/24.
//

import Foundation

class ADManager {
    
    static let shared = ADManager()
    
    var isAdLimitReached: Bool = false
    
    private let adLimit = 3
    
    private var adCount: Int = 0 {
        didSet {
            print("adCount ", adCount)
            isAdLimitReached = (adCount >= adLimit) ? true : false
        }
    }
    
    func adLoaded() {
        self.adCount += 1
    }
    
    func resetCounter() {
        self.adCount = 0
    }
}
