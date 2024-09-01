//
//  Enums.swift
//  Image Picker
//
//  Created by BCL Device-18 on 30/5/24.
//

import Foundation

enum AppType: String {
    case standard = "standard"
    case facebook = "facebook"
    case instagram = "instagram"
    case tiktok = "tiktok"
    case snapchat = "snapchat"
    case pinterest = "pinterest"
    case linkedin = "linkedin"
    case youtube = "youtube"
    case twitter = "twitter"
}

enum DynamicCellState: Int {
    case image = 0
//    case indicator = 1
    case regen = 2
}
