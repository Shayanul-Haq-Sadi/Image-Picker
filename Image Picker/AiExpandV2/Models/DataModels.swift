//
//  DataModels.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/5/24.
//

import Foundation

struct SectionData {
    let title: String
    let appType: AppType
    let items: [Item]
}

struct Item {
    let text: String
    let selectedImage: String
    let nonSelectedImage: String
    let ratio: String
    let resolution: String
}
