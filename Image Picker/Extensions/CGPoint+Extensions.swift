//
//  CGPoint+Extensions.swift
//  Image Picker
//
//  Created by BCL Device-18 on 4/8/24.
//

import UIKit

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - self.x, point.y - self.y)
    }
}
