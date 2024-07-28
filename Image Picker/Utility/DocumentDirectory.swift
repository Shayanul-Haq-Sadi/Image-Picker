//
//  DocumentDirectory.swift
//  Image Picker
//
//  Created by BCL Device-18 on 8/7/24.
//

import UIKit

//// saves an image, if save is successful, returns its URL on local storage, otherwise returns nil
//func saveImage(_ image: UIImage, name: String) -> URL? {
//    guard let imageData = image.jpegData(compressionQuality: 1) else {
//        return nil
//    }
//    do {
//        let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
////        let imageURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("tt")
//        try imageData.write(to: imageURL)
//        return imageURL
//    } catch {
//        return nil
//    }
//}

//// returns an image if there is one with the given name, otherwise returns nil
//func loadImage(withName name: String) -> UIImage? {
//    let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
//    return UIImage(contentsOfFile: imageURL.path)
//}


//func createFileDirectory() {
//    let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//    
//    //set the name of the new folder
//    let folderURL = documentsURL.appendingPathComponent("Temp")
//    do
//    {
//        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
//    }
//    catch let error as NSError
//    {
//        NSLog("Unable to create directory \(error.debugDescription)")
//    }
//}


func writeTempData(_ image: UIImage, name: Int) -> URL? {
    guard let imageData = image.jpegData(compressionQuality: 1) else { return nil }
    
    let folderName = "Temp"
    let fileManager = FileManager.default
    let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let folderURL = documentsFolder.appendingPathComponent(folderName)
    let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false
    do {
        if !folderExists {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
        }
        let fileURL = folderURL.appendingPathComponent("\(name).jpeg")
        try imageData.write(to: fileURL)
        return fileURL
        
    } catch {
        print(error)
        return nil
    }
}

func readTempData(withName name: Int) -> UIImage? {
    let folderName = "Temp"
    let fileManager = FileManager.default
    let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let folderURL = documentsFolder.appendingPathComponent(folderName)
    let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false
    
    if !folderExists {
        return nil
    } else {
        let fileURL = folderURL.appendingPathComponent("\(name).jpeg")
        let image = UIImage(contentsOfFile: fileURL.path)
        return image
    }
    
}


func readTempData(fileURL: URL) -> UIImage? {
    guard let image = UIImage(contentsOfFile: fileURL.path) else { return nil }
    return image
}

func removeTempData() {
    let folderName = "Temp"
    let fileManager = FileManager.default
    let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let folderURL = documentsFolder.appendingPathComponent(folderName)
    do {
        try FileManager.default.removeItem(at: folderURL)
        print("Temp folder remove")
    } catch {
        print(error)
    }

}
