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
    
    var owner: String = ""
    var repo: String = ""
    fileprivate var datasource: [Model.Issue] = []
    @IBOutlet var collectionView: UICollectionView!
    let refreshControl = UIRefreshControl()
    var page: Int = 1
    var canLoadMore: Bool = true
    private var needRefreshDatasource: Bool = false
    var isLoading: Bool = false
    
    func setNeedRefreshDatasource() {
        needRefreshDatasource = true
    }
    func refreshDataSourceIfNeeded() {
        if needRefreshDatasource {
            self.datasource = []
            needRefreshDatasource = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            print("estimatedItemSize")
            print("size : \(CGSize(width: UIScreen.main.bounds.width, height: 56))")
            flowLayout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 256)
        }
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func load() {
        isLoading = true
        API.repoIssues(owner: owner, repo: repo, page: page) {[weak self] (response: DataResponse<[Model.Issue]>) in
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
        datasource = datasource + issues
        page = page + 1
        if issues.count == 0 {
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
        print("item: \(indexPath.item), count: \(datasource.count)")
        if indexPath.item == datasource.count - 1  && !isLoading{
            loadMore()
        }
    }
}
