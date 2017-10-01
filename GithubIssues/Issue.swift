//
//  Issue.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Model {
    public struct Issue {
        let id: Int
        let number: Int
        let title: String
        let user: Model.User
        let state: State
        let comments: Int
        let body: String
        let createdAt: Date?
        let updatedAt: Date?
        let closedAt: Date?
        
        public init(json: JSON) {
            print("issue json: \(json)")
            id = json["id"].intValue
            number = json["number"].intValue
            title = json["title"].stringValue
            user = Model.User(json: json["user"])
            state = State(rawValue: json["state"].stringValue) ?? .none
            comments = json["comments"].intValue
            body = json["body"].stringValue
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            createdAt = format.date(from: json["created_at"].stringValue)
            updatedAt = format.date(from: json["updated_at"].stringValue)
            closedAt = format.date(from: json["closed_at"].stringValue)
        }
    }
}

extension Model.Issue {
    var toDict: [String: Any] {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        var dict: [String : Any] = [
            "id": id,
            "number": number,
            "title": title,
            "comments": comments,
            "body": body,
            "state": state.display,
            "user": [
                "id": user.id,
                "login": user.login,
                "acatar_url": (user.avatarURL?.absoluteString ?? "")]
        ]
        if let createdAt = createdAt {
            dict["createdAt"] = format.string(from: createdAt)
        }
        if let updatedAt = updatedAt {
            dict["updatedAt"] = format.string(from: updatedAt)
        }
        if let closedAt = closedAt {
            dict["closedAt"] = format.string(from: closedAt)
        }
        
        print("dict: \(dict)")
        return dict
        
    }
}

extension Model.Issue {
    enum State: String {
        case open
        case closed
        case none
        
        var display: String {
            switch self {
            case .open: return "opened"
            case .closed: return "closed"
            case .none: return "-"
            }
        }
        
        
    }
}


extension Model.Issue: Equatable {
    public static func ==(lhs: Model.Issue, rhs: Model.Issue) -> Bool {
        return lhs.id == rhs.id
    }
}
