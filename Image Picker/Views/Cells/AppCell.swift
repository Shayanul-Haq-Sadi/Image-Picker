//
//  AppCell.swift
//  Image Picker
//
//  Created by BCL Device-18 on 21/5/24.
//

import UIKit

class AppCell: UICollectionViewCell {
    
    static let identifier = "AppCell"

    @IBOutlet private weak var cellTitleLbl: UILabel!
    @IBOutlet private weak var selectView: UIView!
    
    override var isSelected: Bool {
        didSet {
            cellTitleLbl.textColor = self.isSelected ? .selected : .nonSelected
            selectView.isHidden = self.isSelected ? false : true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        selectView.layer.cornerRadius = 1
        selectView.backgroundColor = .selected
    }
    
    func setup(title: String) {
        cellTitleLbl.text = title
        
        cellTitleLbl.textColor = self.isSelected ? .selected : .nonSelected
        selectView.isHidden = self.isSelected ? false : true
    }
    
}
