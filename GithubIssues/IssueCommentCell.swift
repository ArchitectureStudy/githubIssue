//
//  IssueCommentCell.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import AlamofireImage


class IssueCommentCell: UICollectionViewCell {
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var commentContanerView: UIView!
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        commentContanerView.layer.borderWidth = 1
        commentContanerView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }
    
}

extension IssueCommentCell {
    
    func update(data: Model.Comment, withImage: Bool = true) {
        if let url = data.user.avatarURL, withImage {
            profileImageView.af_setImage(withURL: url)
        }
        
        let createdAt = data.createdAt?.string(dateFormat: "DD MMM yyyy") ?? "-"
        titleLabel.text = "\(data.user.login) commented on \(createdAt)"
        bodyLabel.text = data.body
    }
}
