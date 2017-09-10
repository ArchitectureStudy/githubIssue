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
        guard let owner = ownerTextField.text, let repo = repoTextField.text else { return }
        GlobalState.instance.owner = owner
        GlobalState.instance.repo = repo
        guard let issuesViewController = segue.destination as? IssuesViewController else { return }
        issuesViewController.owner = owner
        issuesViewController.repo = repo
    }
}
