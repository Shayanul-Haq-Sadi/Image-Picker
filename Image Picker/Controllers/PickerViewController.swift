//
//  PickerViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 19/5/24.
//

import UIKit
import Reachability

class PickerViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet private weak var pickerButton: UIButton!
    @IBOutlet private weak var resetADButton: UIButton!
    @IBOutlet private weak var premiumButton: UIButton!
    @IBOutlet private weak var freeButton: UIButton!
    
    var pickedImage: UIImage? = nil
    var imageData: Data!
    
    //declare this property where it won't go out of scope relative to your listener
    let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //declare this inside of viewWillAppear
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
    }
    
    private func setupUI() {
        
    }
    
    private func presentImageViewController(pickedImage: UIImage, imageData: Data) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ImageViewController.identifier) as? ImageViewController else { return }

//        VC.modalPresentationStyle = .fullScreen
//        VC.modalTransitionStyle = .crossDissolve
        VC.pickedImage = pickedImage
        VC.imageData = imageData
//        present(VC, animated: true)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    private func presentExpandViewController(pickedImage: UIImage, imageData: Data) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ExpandViewController.identifier) as? ExpandViewController else { return }

//        VC.modalPresentationStyle = .fullScreen
//        VC.modalTransitionStyle = .crossDissolve
        VC.pickedImage = pickedImage
        VC.imageData = imageData
//        present(VC, animated: true)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    private func presentExpandViewControllerV2(pickedImage: UIImage, imageData: Data/*, completion: @escaping () -> Void*/) {
        guard let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ExpandViewControllerV2.identifier) as? ExpandViewControllerV2 else { return }

        VC.pickedImage = pickedImage
        VC.imageData = imageData
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func pickerButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
//        if reachability.connection == .unavailable {
//            self.showAlert(title: "No Internet!", message: "Please connect and try again later", cancelButtonTitle: "Ok")
//        } else {
            present(imagePicker, animated: true, completion: nil)
//        }
    }

    @IBAction func resetADButtonPressed(_ sender: Any) {
        ADManager.shared.resetCounter()
        self.showAlert(title: "Reset!", message: "AD counter is 0")
    }
    
    @IBAction func premiumButtonPressed(_ sender: Any) {
        PurchaseManager.shared.buy()
        self.showAlert(title: "Premium User!", message: "Enjoy with no ADs")
    }
    
    @IBAction func freeButtonPressed(_ sender: Any) {
        PurchaseManager.shared.restore()
        self.showAlert(title: "Free User!", message: "Buy now to get all features")
    }
    
}


extension PickerViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if self.pickedImage == nil, let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickedImage = pickedImage
            print("pickedImage Width: \(pickedImage.size.width), pickedImage Height: \(pickedImage.size.height)")
            
            guard let fixedOrientationImage = pickedImage.fixedOrientation(), let imageData = fixedOrientationImage.jpegData(compressionQuality: 1.0) else {
                print("Failed to convert image to data")
                return
            }

//            presentImageViewController(pickedImage: pickedImage, imageData: imageData)
//            presentExpandViewController(pickedImage: pickedImage, imageData: imageData)
            picker.dismiss(animated: true) {
                self.presentExpandViewControllerV2(pickedImage: pickedImage, imageData: imageData)
                self.pickedImage = nil
            }
        }
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.pickedImage = nil
        }
    }
}
