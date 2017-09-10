//
//  ViewController.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 9..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        API.getOauthKey(user: "intmain", password: "b57d3a") { (response: DataResponse<JSON>) in
//            switch response.result {
//            case let .success(value):
//                let token = value["token"].stringValue
//                UserDefaults.standard.set(token, forKey: "accessToken")
//            case let .failure(error):
//                print(error)
//            }
//        }
        
        API.repoIssues(owner: "ArchitectureStudy", repo: "study") { (response: DataResponse<[Model.Issue]>) in
            switch response.result {
            case let .success(value):
                print(value)
            case let .failure(error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

