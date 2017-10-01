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

class ListViewController<CellType:UICollectionViewCell & CellProtocol>: UIViewController, DatasourceRefreshable, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias Item = CellType.Item
    var isLoading: Bool = false
    var loadMoreCell: LoadMoreCell?
    @IBOutlet var collectionView: UICollectionView!
    var needRefreshDatasource: Bool = false
    typealias PageIndicator = Int
    var datasource: [Item] = []
    let refreshControl = UIRefreshControl()
    var page: Int = 1
    var canLoadMore: Bool = true
    fileprivate var estimatedSizes: [IndexPath: CGSize] = [:]
    fileprivate let estimateCell: CellType = CellType.cellFromNib
    
    typealias IssueResponsesHandler = (DataResponse<[Item]>) -> Void
    var api: ((Int, @escaping IssueResponsesHandler) -> Void)?
    
    func loadMore(indexPath: IndexPath) {
        guard  indexPath.item == datasource.count - 1 && !isLoading && canLoadMore else { return }
        load()
    }
    
    func setup() {
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        load()
        loadMoreCell?.load()
        
    }
    
    func load() {
        guard isLoading == false else {return }
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
            loadMoreCell?.loadDone()
            
        }
        refreshControl.endRefreshing()
        datasource.append(contentsOf: items)
        collectionView.reloadData()
        
    }
    
    @objc func refresh() {
        page = 1
        canLoadMore = true
        loadMoreCell?.load()
        setNeedRefreshDatasource()
        load()
    }
    
    func cellIdentifier() -> String {
        return ""
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*
         사이즈
         
         인덱싱된 사이즈가 있으면 리턴.
         데이터를 가져옴.
         estimateCell에 데이트 업데이트함.
         가로 사이즈를 받아, 쎌 사이즈를 잼.
         가져온 사이즈를 인덱싱.
         그 사이즈를 리턴.
         
         */
        
        
        var estimatedSize = estimatedSizes[indexPath] ?? CGSize.zero
        if estimatedSize != .zero {
            return estimatedSize
        }
        let data = datasource[indexPath.item]
        
        estimateCell.update(data: data)
        
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        
        estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        estimatedSizes[indexPath] = estimatedSize
        return estimatedSize
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier(), for: indexPath) as! CellType
        let issue = datasource[indexPath.item]
        cell.update(data: issue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize.zero
    }
}
