//
//  Comment.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Model {
    public struct Comment {
        
        let id: Int
        let user: Model.User
        
        let body: String
        let createdAt: Date?
        let updatedAt: Date?
        
        public init(json: JSON) {
            id = json["id"].intValue
            user = Model.User(json: json["user"])
            body = json["body"].stringValue
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            createdAt = format.date(from: json["created_at"].stringValue)
            updatedAt = format.date(from: json["updated_at"].stringValue)
        }
        
    }
}
