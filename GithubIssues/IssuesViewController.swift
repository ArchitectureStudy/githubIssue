//
//  IssuesViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension IssuesViewController {
    func setup() {
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            print("estimatedItemSize")
            print("size : \(CGSize(width: UIScreen.main.bounds.width, height: 56))")
            flowLayout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 56)
        }
        load()
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
        }
        refreshControl.endRefreshing()
        
        print("datasource.count,1:\(datasource.count)")
        datasource.append(contentsOf: issues)
        print("datasource.count,2:\(datasource.count)")
        DispatchQueue.main.async { [weak self] in
        self?.collectionView.reloadData()
        }
        
//        collectionView.reloadSections(IndexSet(integer: 0))
        
    }
    
    func refresh() {
        page = 0
        canLoadMore = true
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
        print("item: \(indexPath.item), count: \(datasource.count)")
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
//        print("item: \(indexPath.item), count: \(datasource.count)")
        if indexPath.item == datasource.count - 1  && !isLoading{
            loadMore()
        }
    }
}

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        return CGSize(width: collectionView.frame.size.width, height: 100)
    }
}
