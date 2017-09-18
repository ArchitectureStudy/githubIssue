//
//  IssueDetailViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

protocol DatasourceRefreshable: class {
    var datasource: [Model.Comment] { get set }
    var needRefreshDatasource: Bool { get set }
}

extension DatasourceRefreshable {
    func setNeedRefreshDatasource() {
        needRefreshDatasource = true
    }
    
    func refreshDataSourceIfNeeded() {
        if needRefreshDatasource {
            datasource = []
            needRefreshDatasource = false
        }
    }
}

class IssueDetailViewController: UIViewController, DatasourceRefreshable {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var headerView: IssueDetailHeaderView!
    @IBOutlet var commentInputBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var commentTextField: UITextField!
    var owner: String = ""
    var repo: String = ""
    var issue: Model.Issue!
    var datasource: [Model.Comment] = []
    var needRefreshDatasource: Bool = false
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var page: Int = 1
    fileprivate var canLoadMore: Bool = true
    fileprivate var isLoading: Bool = false
    fileprivate lazy var estimateCell: IssueCommentCell = { _ in
        let cell = Bundle.main.loadNibNamed("IssueCommentCell", owner: nil, options: nil)?.first
        return cell as! IssueCommentCell
    }()
    fileprivate var estimatedSizes: [IndexPath: CGSize] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}

extension IssueDetailViewController {
    
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { [weak self] (notifiaction: Notification) in
            guard let `self` = self else { return }
            guard let keyboardBounds = notifiaction.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            guard let animationDuration = notifiaction.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            guard let animationCurve = notifiaction.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
            let animationOptions = UIViewAnimationOptions(rawValue: animationCurve)
            
            print(notifiaction.userInfo)
            
            
            
            
            
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
    
    func setup() {
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "IssueCommentCell", bundle: nil), forCellWithReuseIdentifier: "IssueCommentCell")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        var inset = self.collectionView.contentInset
        inset.bottom = 46
        self.collectionView.contentInset = inset
        
        title = "#\(issue!.number)"
        loadHeaderView()
        load()
    }
    func loadHeaderView() {
        if let issue = issue {
            headerView.update(data: issue)
            collectionView.addSubview(headerView)
            var targetSize  = CGSize(width: collectionView.frame.width, height: 0)
            
            let size = headerView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: UILayoutPriorityRequired,
                verticalFittingPriority: UILayoutPriorityDefaultLow
            )
            
            let width = size.width == 0 ? headerView.bounds.width : size.width
            let height = size.height == 0 ? headerView.bounds.height : size.height
            let viewSize = CGSize(width: width, height: height)
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            headerView.frame.size.width = collectionView.frame.width
            headerView.frame = CGRect(x: 0, y: -viewSize.height, width: viewSize.width, height: viewSize.height)
            collectionView.contentInset = UIEdgeInsets(top: headerView.frame.height, left: 0, bottom: 0, right: 0)
        }
    }
}

extension IssueDetailViewController {
    @IBAction func sendButtonTapped(_ sender: Any) {
        let comment = commentTextField.text ?? ""
        API.createComment(owner: owner, repo: repo, number: issue.number, comment: comment) { [weak self] (dataResponse: DataResponse<Model.Comment>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let comment):
                self.addComment(comment: comment)
                self.commentTextField.text = ""
                self.commentTextField.resignFirstResponder()
                
                break
            case .failure(_):
                break
            }
        }
    }
    
    @IBAction func stateButtonTapped(_ sender: Any) {
        chagneState()
    }
}

extension IssueDetailViewController {
    func load() {
        isLoading = true
        API.issueDetail(owner: owner , repo: repo, number: issue.number, page: page) { [weak self] (response: DataResponse<[Model.Comment]>) in
            guard let `self` = self else { return }
            switch response.result {
            case .success(let comments):
                self.dataLoaded(comments: comments)
                self.isLoading = false
            case .failure(_):
                self.isLoading = false
            }
        }
    }
    
    func addComment(comment: Model.Comment) {
        let newIndexPath = IndexPath(item: datasource.count, section: 0)
        datasource.append(comment)
        collectionView.insertItems(at: [newIndexPath])
        
        collectionView.scrollToItem(at: newIndexPath, at: .bottom, animated: true)
        
    }
    
    func dataLoaded(comments: [Model.Comment]) {
        refreshDataSourceIfNeeded()
        datasource = datasource + comments
        page = page + 1
        if comments.count == 0 {
            canLoadMore = false
        }
        refreshControl.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.collectionView.reloadData()
        }
        
        collectionView.reloadData()
    }
    
    func refresh() {
        page = 1
        canLoadMore = true
        setNeedRefreshDatasource()
        load()
    }
    
    func loadMore() {
        if canLoadMore {
            load()
        }
    }
    
    func chagneState() {
        switch issue.state {
        case .open, .none:
            API.closeIssue(owner: owner, repo: repo, number: issue.number, issue: issue, completionHandler: { [weak self] (dataResponse: DataResponse<Model.Issue>) in
                switch dataResponse.result {
                case .success(let issue):
                    print("issue: \(issue)")
                    self?.issue = issue
                    self?.loadHeaderView()
                case .failure(let error):
                    print(dataResponse.request)
                    print(error)
                }
                
            })
        case .closed:
            API.openIssue(owner: owner, repo: repo, number: issue.number, issue: issue, completionHandler: { [weak self] (dataResponse: DataResponse<Model.Issue>) in
                switch dataResponse.result {
                case .success(let issue):
                    print("issue: \(issue)")
                    self?.issue = issue
                    self?.loadHeaderView()
                case .failure(let error):
                    print(dataResponse.request)
                    print(error)
                }
            })
        }
    }
}

extension IssueDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueCommentCell", for: indexPath) as! IssueCommentCell
        let comment = datasource[indexPath.item]
        cell.update(data: comment)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
}

extension IssueDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("item: \(indexPath.item), count: \(datasource.count)")
        if indexPath.item == datasource.count - 1  && !isLoading{
            loadMore()
        }
    }
}

extension IssueDetailViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 8*2
        let targetSize = CGSize(width: width, height: 48)
        
        var estimatedSize = estimatedSizes[indexPath] ?? CGSize.zero
        if estimatedSize != .zero {
            return estimatedSize
        }
        
        let data = datasource[indexPath.item]
        estimateCell.update(data: data, withImage: false)
        
        
        estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        estimatedSizes[indexPath] = estimatedSize
        
        return estimatedSize
    }
}
