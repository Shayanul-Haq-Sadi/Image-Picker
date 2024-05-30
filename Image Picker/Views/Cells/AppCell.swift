//
//  AppCell.swift
//  Image Picker
//
//  Created by BCL Device-18 on 21/5/24.
//

import UIKit

class AppCell: UICollectionViewCell {
    
    static let identifier = "AppCell"

    @IBOutlet weak var cellTitleLbl: UILabel!
    @IBOutlet weak var selectView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        selectView.layer.cornerRadius = 1
        selectView.backgroundColor = .selected
    }
    
    func setup(title: String, isSelected: Bool = false) {
        cellTitleLbl.text = title
        cellTitleLbl.textColor = isSelected ? .selected : .nonSelected
        selectView.isHidden = isSelected ? false : true
    }
    
}
