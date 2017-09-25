//
//  IssueCommentCell.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import AlamofireImage


final class IssueCommentCell: UICollectionViewCell, CellProtocol {
    
    
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
    func update(data: Model.Comment) {
        update(data: data, withImage: true)
    }
    
    typealias Item = Model.Comment
    
    func update(data comment: Model.Comment, withImage: Bool = true) {
        if let url = comment.user.avatarURL {
            profileImageView.af_setImage(withURL: url)
        }
        
        let createdAt = comment.createdAt?.string(dateFormat: "DD MMM yyyy") ?? "-"
        titleLabel.text = "\(comment.user.login) commented on \(createdAt)"
        bodyLabel.text = comment.body
    }

    static var cellFromNib: IssueCommentCell {
        get {
            return Bundle.main.loadNibNamed("IssueCommentCell", owner: nil, options: nil)?.first as! IssueCommentCell
        }
    }
}
