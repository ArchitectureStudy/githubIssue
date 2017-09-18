//
//  IssueCell.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

class IssueCell: UICollectionViewCell, LayoutEstimatable {
    static var estimatedLayout: [IndexPath: CGSize] = [:]
    
    @IBOutlet var stateButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var commentCountButton: UIButton!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = self.estimateLayoutAttributes(layoutAttributes)
        
        print("preferredLayoutAttributesFitting:\(layoutAttributes.bounds.size), item: \(layoutAttributes.indexPath.item)")
        return layoutAttributes
    }
}


extension IssueCell {
    func update(issue: Model.Issue) {
        titleLabel.text = issue.title
        contentLabel.text = issue.body
        let createdAt = issue.createdAt?.string(dateFormat: "DD MMM yyyy") ?? "-"
        contentLabel.text = "#\(issue.number) \(issue.state.display) on \(createdAt) by \(issue.user.login)"
        commentCountButton.setTitle("\(issue.comments)", for: .normal)
        stateButton.isSelected = issue.state == .closed
    }
}

extension Date {
    func string(dateFormat: String, locale: String = "en-US") -> String {
        let format = DateFormatter()
        format.dateFormat = dateFormat
        format.locale = Locale(identifier: locale)
        return format.string(from: self)
    }
}
