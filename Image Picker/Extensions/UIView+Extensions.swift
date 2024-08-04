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
    
    func addToWindow() {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            self.frame = window.bounds
            window.addSubview(self)
        }
    }
    
    func addToKeyWindow() {
        if let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
            
            self.frame = keyWindow.bounds
            keyWindow.addSubview(self)
        }
    }
    
    func getWindowBounds() -> CGRect {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return .zero }
        return window.bounds
    }
    
    
    
    func distanceFromCenter(to point: CGPoint) -> CGFloat {
        // Get the center of the UIView
        let viewCenter = self.center
        
        // Calculate the differences in x and y
        let deltaX = viewCenter.x - point.x
        let deltaY = viewCenter.y - point.y
        
        // Use hypot to calculate the distance
        return hypot(deltaX, deltaY)
    }
    
    enum Edge {
        case top
        case bottom
        case left
        case right
    }
    
    func closestDistance(to point: CGPoint) -> (distance: CGFloat, edge: Edge) {
        // Get the frame of the view in its superview's coordinate space
        let viewFrame = self.frame
        
        // Calculate distances to each edge
        let distanceToLeft = abs(point.x - viewFrame.minX)
        let distanceToRight = abs(point.x - viewFrame.maxX)
        let distanceToTop = abs(point.y - viewFrame.minY)
        let distanceToBottom = abs(point.y - viewFrame.maxY)
        
        // Determine the minimum distance and corresponding edge
        let minDistance = min(distanceToLeft, distanceToRight, distanceToTop, distanceToBottom)
        let closestEdge: Edge
        
        switch minDistance {
            case distanceToLeft:
                closestEdge = .left
            case distanceToRight:
                closestEdge = .right
            case distanceToTop:
                closestEdge = .top
            case distanceToBottom:
                closestEdge = .bottom
            default:
                closestEdge = .top // Default case to avoid uninitialized variable error
        }
        
        return (minDistance, closestEdge)
    }
    
    
}
