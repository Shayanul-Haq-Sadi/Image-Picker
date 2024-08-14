//
//  DownloadCellV2.swift
//  Image Picker
//
//  Created by BCL Device-18 on 3/7/24.
//

import UIKit
import APNGKit

class DownloadCellV2: UICollectionViewCell {
    
    static let identifier = "DownloadCellV2"
    
    @IBOutlet private weak var backgroundImage: UIImageView!
    
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var downloadedImage: UIImageView!
    @IBOutlet private weak var selectorImage: UIImageView!
    
    
    @IBOutlet private weak var indicatorContainerView: UIView!
    @IBOutlet private weak var activityIndicatorView: APNGImageView!
    private var activityIndicatorImage: APNGImage!
    
    @IBOutlet private weak var regenerateContainerView: UIView!
    @IBOutlet private weak var regenerateImage: UIImageView!
    
    private var state: DynamicCellState = .image
    
    override var isSelected: Bool {
        didSet {
            selectorImage.isHidden = self.isSelected ? false : true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addActivityIndicatorView()
        
    }
    
    private func setupUI() {
        imageContainerView.layer.cornerRadius = 12
        imageContainerView.clipsToBounds = true
        
        indicatorContainerView.layer.cornerRadius = 12
        
        regenerateContainerView.layer.cornerRadius = 12
    }
    
    
    func setup(image: UIImage, state: DynamicCellState) {
        downloadedImage.image = image
        
        selectorImage.isHidden = self.isSelected ? false : true
        
        switch state {
        case .image:
            imageVisibility()
//        case .indicator:
//            indicatorVisibility()
        case .regen:
            regenVisibility()
        }
        
    }
    
    private func imageVisibility() {
        imageContainerView.isHidden = false
        indicatorContainerView.isHidden = true
        regenerateContainerView.isHidden = true
        
        activityIndicatorView.stopAnimating()
    }
    
    private func indicatorVisibility() {
        indicatorContainerView.isHidden = false
        imageContainerView.isHidden = true
        regenerateContainerView.isHidden = true
        
        activityIndicatorView.startAnimating()
    }
    
    private func regenVisibility() {
        regenerateContainerView.isHidden = false
        indicatorContainerView.isHidden = true
        imageContainerView.isHidden = true
    
        activityIndicatorView.stopAnimating()
    }
    
    
    private func addActivityIndicatorView() {
        do {
            if let url = Bundle.main.url(forResource: "Loading 1", withExtension: "png") {
                activityIndicatorImage = try APNGImage(fileURL: url, decodingOptions: .fullFirstPass)
                activityIndicatorView.autoStartAnimationWhenSetImage = false
                activityIndicatorView.image = activityIndicatorImage
            }
        } catch {
            if let normalImage = error.apngError?.normalImage {
                activityIndicatorView.staticImage = normalImage
            } else {
                print("Error: \(error)")
            }
        }

//        activityIndicatorView.onOnePlayDone.delegate(on: self) { (self, count) in
//            print("Played: \(count)")
//        }
    }

}
