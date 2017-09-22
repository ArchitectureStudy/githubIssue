//
//  ListViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

protocol DatasourceRefreshable: class {
    associatedtype Item
    var datasource: [Item] { get set }
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

protocol Loadmoreable: class {
    associatedtype Item
    associatedtype PageIndicator
    var datasource: [Item] { get set }
    var canLoadMore: Bool { get set }
    var page: PageIndicator { get set }
    var isLoading: Bool { get set }
    func load()
}

extension Loadmoreable {
    func loadMore() {
        if canLoadMore {
            load()
        }
    }
}

class ListViewController<Item>: UIViewController, DatasourceRefreshable {
    var isLoading: Bool = false
    @IBOutlet var loadMoreView: LoadMoreView!
    
    var needRefreshDatasource: Bool = false
    
    typealias PageIndicator = Int
    
    @IBOutlet var collectionView: UICollectionView!
    var datasource: [Item] = []
    let refreshControl = UIRefreshControl()
    var page: Int = 1
    var canLoadMore: Bool = true
    
    typealias IssueResponsesHandler = (DataResponse<[Item]>) -> Void
    var api: ((Int, @escaping IssueResponsesHandler) -> Void)?
    
    func loadMore(indexPath: IndexPath) {
        guard  indexPath.item == datasource.count - 1 && !isLoading && canLoadMore else { return }
        load()
    }
    
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
    
    func load() {
        isLoading = true
        api?(page, {[weak self] (response: DataResponse<[Item]>) -> Void in
            guard let `self` = self else { return }
            switch response.result {
            case .success(let items):
                self.dataLoaded(items: items)
                self.isLoading = false
            case .failure(_):
                self.isLoading = false
                break
            }
            
        })
        
    }
    
    func dataLoaded(items: [Item]) {
        refreshDataSourceIfNeeded()
        
        page = page + 1
        if items.count == 0 {
            canLoadMore = false
            loadMoreView.loadDone()
            
        }
        refreshControl.endRefreshing()
        datasource.append(contentsOf: items)
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.layoutFooter()
        }
        
    }
    
    @objc func refresh() {
        page = 0
        canLoadMore = true
        loadMoreView.load()
        setNeedRefreshDatasource()
        load()
    }
    
}
