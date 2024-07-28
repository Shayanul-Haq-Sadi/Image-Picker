//
//  CustomCompositionalLayout.swift
//  Image Picker
//
//  Created by BCL Device-18 on 3/7/24.
//

import UIKit

class CustomCompositionalLayout: UICollectionViewLayout {
    
    static let appLayout = CustomCompositionalLayout().createAppLayout()
    
    static let aspectLayout = CustomCompositionalLayout().createAspectLayout()
    
    static let downloadLayout = CustomCompositionalLayout().createDownloadLayout()
    
    
    private func createAppLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection?  in
            return self.createAppSection()
        }, configuration: configuration)
        
        return layout
    }
    
    private func createAspectLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection?  in
            return self.createAspectSection()
        }, configuration: configuration)
        
        return layout
    }
    
    private func createDownloadLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection?  in
            return self.createDownloadSection()
        }, configuration: configuration)
        
        return layout
    }
    
    private func createAppSection() -> NSCollectionLayoutSection {
        print("App Section")
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .fractionalHeight(1)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(67), heightDimension: .absolute(30)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets.leading = 6
        section.contentInsets.trailing = 6
        
        return section
    }
    
    
    private func createAspectSection() -> NSCollectionLayoutSection {
        print("Aspect Section")

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .absolute(120)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets.leading = 22
        section.contentInsets.trailing = 22
        
        return section
    }
    
    
    private func createDownloadSection() -> NSCollectionLayoutSection {
        print("Download Section")
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(76), heightDimension: .absolute(76)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets.leading = 22
        section.contentInsets.trailing = 22
        
        return section
    }
    
}
