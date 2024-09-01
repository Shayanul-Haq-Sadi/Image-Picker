//
//  DataManager.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/5/24.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    
    private var datasource: Dictionary = Dictionary<String, Any>()
    
    func prepareDatasource() {
        if let plistPath = Bundle.main.path(forResource: "AiExpandV2Datasource", ofType: "plist") {
            // Read datasource data
            if let plistData = FileManager.default.contents(atPath: plistPath) {
                do {
                    // Deserialize datasource data
                    if let datasource = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
                        self.datasource = datasource
                    } else {
                        print("Failed to deserialize datasource data.")
                    }
                } catch {
                    print("Error reading datasource data: \(error)")
                }
            } else {
                print("Failed to load datasource data.")
            }
        } else {
            print("datasource file not found.")
        }
    }
    
    func getSupportedAppsRootDataCount() -> Int? {
        guard let rootValue = self.datasource["Supported Apps V2"] as? [[String: Any]] else { return nil }
        return rootValue.count
    }
    
    func getSupportedAspectRootDataCount(of section: Int) -> Int? {
        guard let rootValue = self.datasource["Supported Apps V2"] as? [[String: Any]],
              let sectionData = self.parseDictionary(dictionary: rootValue[section])
        else { return nil }
        return sectionData.items.count
    }

    func getSupportedAppsData(of section: Int) -> SectionData? {
        guard let rootValue = self.datasource["Supported Apps V2"] as? [[String: Any]],
              let sectionData = self.parseDictionary(dictionary: rootValue[section])
        else { return nil }
        return sectionData
    }
    
    func getSupportedAspectData(of section: Int) -> [Item]? {
        guard let rootValue = self.datasource["Supported Apps V2"] as? [[String: Any]],
              let sectionData = self.parseDictionary(dictionary: rootValue[section])
        else { return nil }
        return sectionData.items
    }
    
    func parseDictionary(dictionary: [String: Any]) -> SectionData? {
        guard
              let title = dictionary["title"] as? String,
              let appType = AppType(rawValue: title.lowercased()),
              let itemsArray = dictionary["items"] as? [[String: Any]]
        else { return nil }

        // Parse items
        var items: [Item] = []
        for itemDict in itemsArray {
            if let text = itemDict["text"] as? String,
               let selectedImage = itemDict["selectedImage"] as? String,
               let nonSelectedImage = itemDict["nonSelectedImage"] as? String,
               let ratio = itemDict["ratio"] as? String,
               let resolution = itemDict["resolution"] as? String {
                let item = Item(text: text, selectedImage: selectedImage, nonSelectedImage: nonSelectedImage, ratio: ratio, resolution: resolution)
                items.append(item)
            }
        }

        let sectionData = SectionData(title: title, appType: appType, items: items)
        return sectionData
    }
}
