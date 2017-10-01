//
//  RepoViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

class RepoViewController: UIViewController {

    @IBOutlet var ownerTextField: UITextField!
    @IBOutlet var repoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ownerTextField.text = GlobalState.instance.owner
        repoTextField.text = GlobalState.instance.repo
        
//        repoTextField.layer.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let owner = ownerTextField.text, let repo = repoTextField.text else { return false }
        return !(owner.isEmpty || repo.isEmpty)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EnterRepoSegue" {
            guard let owner = ownerTextField.text, let repo = repoTextField.text else { return }
            GlobalState.instance.owner = owner
            GlobalState.instance.repo = repo
            GlobalState.instance.addRepo(owner: owner, repo: repo)
            guard let issuesViewController = segue.destination as? IssuesViewController else { return }
            issuesViewController.owner = owner
            issuesViewController.repo = repo
        }
    }
    
    @IBAction func unwindFromRepos(_ segue: UIStoryboardSegue) {
        if let reposViewController = segue.source as?  ReposViewController, let (owner, repo) = reposViewController.selectedRepo {
            ownerTextField.text = owner
            repoTextField.text = repo
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "EnterRepoSegue", sender: nil)
            }
            
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any?) {
        GlobalState.instance.token = ""
        let loginViewController = LoginViewController.viewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: { [weak self] in
            self?.present(loginViewController, animated: true, completion: nil)
        })
    }
}
