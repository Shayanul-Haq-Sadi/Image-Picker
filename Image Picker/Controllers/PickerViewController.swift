//
//  PickerViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 19/5/24.
//

import UIKit

class PickerViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var pickerButton: UIButton!
    
    var pickedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    @IBAction func pickerButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

}


extension PickerViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickedImage = pickedImage
            print("pickedImage Width: \(self.pickedImage.size.width), pickedImage Height: \(self.pickedImage.size.height)")
            
            guard let fixedOrientationImage = pickedImage.fixedOrientation(), let imageData = fixedOrientationImage.jpegData(compressionQuality: 1.0) else {
                print("Failed to convert image to data")
                return
            }

//            presentImageViewController(pickedImage: pickedImage, imageData: imageData)
            presentExpandViewController(pickedImage: pickedImage, imageData: imageData)
            
        }
        dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
