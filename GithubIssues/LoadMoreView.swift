//
//  LoadMoreView.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

class LoadMoreView: UIView {
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var doneView: UIView!
    
}

extension LoadMoreView {
    func loadDone() {
        activityIndicatorView.isHidden = true
        doneView.isHidden = false
    }
    
    func load() {
        activityIndicatorView.isHidden = false
        doneView.isHidden = true
    }
}
