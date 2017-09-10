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

class LoginViewController: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
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
    @IBAction func loginButtonTapped(_ sender: Any) {
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        API.getOauthKey(user: id, password: password) { [weak self] (response: DataResponse<JSON>) in
            switch response.result {
            case let .success(value):
                print(value)
                let token = value["token"].stringValue
                GlobalState.instance.token = token
                self?.dismiss(animated: true, completion: { 
                    
                })
            case let .failure(error):
                print(error)
            }
        }
    }
}
