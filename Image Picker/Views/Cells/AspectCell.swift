//
//  AspectCell.swift
//  Image Picker
//
//  Created by BCL Device-18 on 20/5/24.
//

import UIKit

class AspectCell: UICollectionViewCell {

    static let identifier = "AspectCell"

    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {

    }
    
    func setup(image: String, isSelected: Bool = false) {
        cellImageView.image = UIImage(named: image)
        cellImageView.tintColor = isSelected ? .selected : .nonSelected
    }

}
