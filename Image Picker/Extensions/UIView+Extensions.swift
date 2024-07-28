//
//  UIView+Extensions.swift
//  Image Picker
//
//  Created by BCL Device-18 on 9/7/24.
//

import UIKit


extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    
    func edgeDistancesToSuperview() -> (top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat)? {
        guard let superview = self.superview else { return nil }
        
        let topDistance = round(self.frame.origin.y)
        let bottomDistance = round(superview.frame.height - (self.frame.origin.y + self.frame.height))
        let leadingDistance = round(self.frame.origin.x)
        let trailingDistance = round(superview.frame.width - (self.frame.origin.x + self.frame.width))
        
        return (top: topDistance, bottom: bottomDistance, leading: leadingDistance, trailing: trailingDistance)
    }
    
}
