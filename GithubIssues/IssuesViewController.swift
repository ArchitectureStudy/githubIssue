//
//  IssuesViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

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


protocol Feed: class {
    var collectionView: UICollectionView! { get set }
    var datasource: [Model.Issue] { get set }
    var refreshControl: UIRefreshControl { get set }
    var canLoadMore: Bool { get set }
    
}

class IssuesViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    var owner: String = ""
    var repo: String = ""
    fileprivate var datasource: [Model.Issue] = []
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var page: Int = 0
    fileprivate var canLoadMore: Bool = true
    fileprivate var needRefreshDatasource: Bool = false
    fileprivate var isLoading: Bool = false
    fileprivate var estimatedSizes: [IndexPath: CGSize] = [:]
    fileprivate let estimateCell: IssueCell = IssueCell.cellFromNib
    @IBOutlet fileprivate var loadMoreView: LoadMoreView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension IssuesViewController {
    func setup() {
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        load()
        footer()
        loadMoreView.load()
    }
    
    func layoutFooter() {
        loadMoreView.frame.origin.y = collectionView.contentSize.height
        loadMoreView.frame.size.width = collectionView.frame.width
        loadMoreView.frame.size.height = 50
    }
    func footer() {
        collectionView.addSubview(loadMoreView)
        var inset = collectionView.contentInset
        inset.bottom = 50
        collectionView.contentInset = inset
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? IssueDetailViewController,
            let cell = sender as? IssueCell,
            let indexPath = collectionView.indexPath(for: cell) {
            let issue = datasource[indexPath.item]
            detailViewController.issue = issue
            detailViewController.repo = repo
            detailViewController.owner = owner
        } else if let navigationController = segue.destination as? UINavigationController, let createIssueViewController = navigationController.topViewController as? CreateIssueViewController {
            createIssueViewController.repo = repo
            createIssueViewController.owner = owner
        }
    }
    
    @IBAction func unwindFromCreate(_ segue: UIStoryboardSegue) {
        if let createViewController = segue.source as? CreateIssueViewController, let createdIssue = createViewController.createdIssue {
            datasource.insert(createdIssue, at: 0)
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            
        }
        
    }
}

extension IssuesViewController {
    func setNeedRefreshDatasource() {
        needRefreshDatasource = true
    }
    
    func refreshDataSourceIfNeeded() {
        if needRefreshDatasource {
            self.datasource = []
            collectionView.reloadData()
            needRefreshDatasource = false
        }
    }
}

extension IssuesViewController {
    func load() {
        isLoading = true
        API.repoIssues(owner: owner, repo: repo, page: page + 1) {[weak self] (response: DataResponse<[Model.Issue]>) in
            guard let `self` = self else { return }
            switch response.result {
            case .success(let issues):
                self.dataLoaded(issues: issues)
                self.isLoading = false
            case .failure(_):
                self.isLoading = false
                break
            }
        }
    }
    
    func dataLoaded(issues: [Model.Issue]) {
        refreshDataSourceIfNeeded()
        
        page = page + 1
        if issues.count == 0 {
            canLoadMore = false
            loadMoreView.loadDone()
            
        }
        refreshControl.endRefreshing()
        
        datasource.append(contentsOf: issues)
        
        print("collectionView.frame1: \(collectionView.contentSize)")
        collectionView.reloadData()
        print("collectionView.frame2: \(collectionView.contentSize)")
        
        DispatchQueue.main.async { [weak self] in
            self?.layoutFooter()
        }
        print("collectionView.frame3: \(collectionView.contentSize)")
        
    }
    
    func refresh() {
        page = 0
        canLoadMore = true
        loadMoreView.load()
        setNeedRefreshDatasource()
        load()
    }
    
    func loadMore() {
        if canLoadMore {
            load()
        }
    }
}

extension IssuesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueCell", for: indexPath) as! IssueCell
        let issue = datasource[indexPath.item]
        cell.update(issue: issue)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    
}

extension IssuesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == datasource.count - 1  && !isLoading{
            loadMore()
        }
    }
}

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var estimatedSize = estimatedSizes[indexPath] ?? CGSize.zero
        if estimatedSize != .zero {
            return estimatedSize
        }
        let data = datasource[indexPath.item]
        
        estimateCell.update(issue: data)
        
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        
        estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        estimatedSizes[indexPath] = estimatedSize
        
        return estimatedSize
    }
}
