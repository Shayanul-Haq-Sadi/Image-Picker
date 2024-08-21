//
//  AppManager.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/8/24.
//

import Foundation

class AppManager {
    
    static let shared = AppManager()
    
    private(set) var fixedResolutionFlow: Bool = false
    
    private init() { }
    
    func enable() {
        fixedResolutionFlow = true
    }
    
    func disable() {
        fixedResolutionFlow = false
    }
}
