//
//  LoginViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import OAuthSwift

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static var viewController: LoginViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        return viewController
    }
    @IBAction func githubLoginButtonTapped(_ sender: Any) {
        App.api.getToekn { [weak self] in
            self?.dismiss(animated: true, completion: {
            })
        }
    }
    
    @IBAction func bitbucketLoginButtonTapped(_ sender: Any) {
        App.api.getToekn { [weak self] in
            self?.dismiss(animated: true, completion: {
            })
        }
    }
}
