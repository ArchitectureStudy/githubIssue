//
//  User.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Model {
    public struct User {
        let id: Int
        let login: String
        let avatarURL: URL?
        
        public init(json: JSON) {
            id = json["id"].intValue
            login = json["login"].stringValue
            
            avatarURL = URL(string: json["avatar_url"].stringValue)
        }
        
    }
}
