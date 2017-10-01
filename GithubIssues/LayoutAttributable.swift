//
//  LayoutAttributable.swift
//  TaewanArchitectureStudy
//
//  Created by taewan on 2017. 2. 11..
//  Copyright © 2017년 taewankim. All rights reserved.
//

import UIKit

protocol LayoutEstimatable: class {
    static var estimatedLayout: [IndexPath: CGSize] { get set }
    static func estimatedSizeReset(indexPath: IndexPath?)
}

extension LayoutEstimatable where Self: UICollectionViewCell {
    static func estimatedSizeReset(indexPath: IndexPath? = nil) {
        if let key = indexPath {
            estimatedLayout[key] = nil
        } else {
            estimatedLayout = [:]
        }
    }
    
    func estimateLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if layoutAttributes.isHidden {
            return layoutAttributes
        }
        
        if let layoutSize = Self.estimatedLayout[layoutAttributes.indexPath] {
            layoutAttributes.size = layoutSize
        } else {
            layoutAttributes.size = contentView.systemLayoutSizeFitting(
                layoutAttributes.size,
                withHorizontalFittingPriority: UILayoutPriorityRequired,
                verticalFittingPriority: UILayoutPriorityDefaultLow)
            Self.estimatedLayout[layoutAttributes.indexPath] = layoutAttributes.size
        }
        return layoutAttributes
    }
    
}
