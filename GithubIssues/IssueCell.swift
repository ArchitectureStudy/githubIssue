//
//  IssueCell.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

class IssueCell: UICollectionViewCell {

    @IBOutlet var stateButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var commentCountButton: UIButton!
}

extension IssueCell {
    static var cellFromNib: IssueCell {
        get {
            return Bundle.main.loadNibNamed("IssueCell", owner: nil, options: nil)?.first as! IssueCell
        }
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
