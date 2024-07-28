//
//  AspectCellV2.swift
//  Image Picker
//
//  Created by BCL Device-18 on 7/7/24.
//

import UIKit

class AspectCellV2: UICollectionViewCell {
    
    static let identifier = "AspectCellV2"
    
    @IBOutlet private weak var cellImageView: UIImageView!
    
    private var selectedImage: UIImage!
    
    private var nonSelectedImage: UIImage!
    
    override var isSelected: Bool {
        didSet {
            cellImageView.image = self.isSelected ? selectedImage : nonSelectedImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {

    }
        
    func setup(selectedImage: String, nonSelectedImage: String) {
        self.selectedImage = UIImage(named: selectedImage)
        self.nonSelectedImage = UIImage(named: nonSelectedImage)
        
        cellImageView.image = self.isSelected ? self.selectedImage : self.nonSelectedImage
    }

}
