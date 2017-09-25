//
//  IssuesViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire

final class IssuesViewController: ListViewController<IssueCell>  {
    var owner: String = ""
    var repo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = API.repoIssues(owner: owner, repo: repo)
        collectionView.delegate = self
        collectionView.dataSource = self
        setup()
        
    }
    
    override func setup() {
        super.setup()
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? IssueDetailViewController,let issue = sender as? Model.Issue {
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = datasource[indexPath.item]
        self.performSegue(withIdentifier: "PushIssueDetail", sender: data)
    }
    
    
    override func cellIdentifier() -> String {
        return "IssueCell"
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            assert(false, "Unexpected element kind")
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreCell ?? LoadMoreCell()
            
            loadMoreCell = footerView
            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
}
