//
//  IssueDetailViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

class IssueDetailViewController: ListViewController<IssueCommentCell> {

    @IBOutlet var commentInputBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var commentTextField: UITextField!
    var owner: String = ""
    var repo: String = ""
    var issue: Model.Issue!
    var headerSize: CGSize = CGSize.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = App.api.issueComment(owner: owner, repo: repo, number: issue.number)
        setup()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNOtification()
    }
    
    override func setup() {
        super.setup()
        var inset = self.collectionView.contentInset
        inset.bottom = 46
        self.collectionView.contentInset = inset
        collectionView.register(UINib(nibName: "IssueCommentCell", bundle: nil), forCellWithReuseIdentifier: "IssueCommentCell")
        title = "#\(issue!.number)"
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let comment = commentTextField.text ?? ""
        App.api.createComment(owner: owner, repo: repo, number: issue.number, comment: comment) { [weak self] (dataResponse: DataResponse<Model.Comment>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let comment):
                self.addComment(comment: comment)
                self.commentTextField.text = ""
                self.commentTextField.resignFirstResponder()
                
                break
            case .failure:
                break
            }
        }
    }
    
    @IBAction func stateButtonTapped(_ sender: Any) {
        chagneState()
    }
    
    override func cellIdentifier() -> String {
        return "IssueCommentCell"
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath) as? IssueDetailHeaderCell ?? IssueDetailHeaderCell()
            
            headerView.update(data: issue)
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreCell ?? LoadMoreCell()
            
            loadMoreCell = footerView
            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if headerSize == CGSize.zero {
            headerSize = IssueDetailHeaderCell.headerSize(issue: issue, width: collectionView.frame.width)
            
        }
        return headerSize
    }
}

extension IssueDetailViewController {
    
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { [weak self] (notifiaction: Notification) in
            guard let `self` = self else { return }
            guard let keyboardBounds = notifiaction.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            guard let animationDuration = notifiaction.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            guard let animationCurve = notifiaction.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
            let animationOptions = UIViewAnimationOptions(rawValue: animationCurve)
            let keyboardHeight = keyboardBounds.height
            let inputBottom = self.view.frame.height - keyboardBounds.origin.y
            print("inputBottom: \(inputBottom)")
            print("keyboard: \(keyboardHeight)")
            var inset = self.collectionView.contentInset
            inset.bottom = inputBottom + 46
            self.collectionView.contentInset = inset
            self.commentInputBottomConstraint.constant = inputBottom
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func removeKeyboardNOtification() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension IssueDetailViewController {

}

extension IssueDetailViewController {
    func addComment(comment: Model.Comment) {
        let newIndexPath = IndexPath(item: datasource.count, section: 0)
        datasource.append(comment)
        collectionView.insertItems(at: [newIndexPath])
        
        collectionView.scrollToItem(at: newIndexPath, at: .bottom, animated: true)
        
    }

    func chagneState() {
        switch issue.state {
        case .open, .none:
            App.api.closeIssue(owner: owner, repo: repo, number: issue.number, issue: issue, completionHandler: { [weak self] (dataResponse: DataResponse<Model.Issue>) in
                switch dataResponse.result {
                case .success(let issue):
                    print("issue: \(issue)")
                    self?.issue = issue
                case .failure(let error):
                    print(error)
                }
                
            })
        case .closed:
            App.api.openIssue(owner: owner, repo: repo, number: issue.number, issue: issue, completionHandler: { [weak self] (dataResponse: DataResponse<Model.Issue>) in
                switch dataResponse.result {
                case .success(let issue):
                    print("issue: \(issue)")
                    self?.issue = issue
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}
