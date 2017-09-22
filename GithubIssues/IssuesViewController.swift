//
//  IssuesViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

final class IssuesViewController: ListViewController<Model.Issue>, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    var owner: String = ""
    var repo: String = ""

 
    fileprivate var estimatedSizes: [IndexPath: CGSize] = [:]
    fileprivate let estimateCell: IssueCell = IssueCell.cellFromNib
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = API.repoIssues(owner: owner, repo: repo)// as? ((Int, @escaping (DataResponse<[Model.Issue]>) -> Void) -> Void)

        setup()
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        loadMore(indexPath: indexPath)
        
    }
    
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
