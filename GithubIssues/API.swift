//
//  API.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct API {
    static func getOauthKey(user: String, password: String, completionHandler: @escaping (DataResponse<JSON>) -> Void) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        let parameters: Parameters = ["client_secret": Router.clientSecret , "scopes": ["public_repo"], "note": "admin script" ]
        Alamofire.request(Router.authKey(parameters, headers))
            .responseSwiftyJSON { json in
                print(json)
                completionHandler(json)
        }
    }
    
    static func repoIssues(owner: String, repo: String, page: Int, completionHandler: @escaping (DataResponse<[Model.Issue]>) -> Void) {
        let parameters: Parameters = ["page": page, "state": "all"]
        Alamofire.request(Router.repoIssues(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> [Model.Issue] in
                return json.arrayValue.map{
                    Model.Issue(json: $0)
                }
            })
            completionHandler(result)
        }
    }
    
    typealias IssueResponsesHandler = (DataResponse<[Model.Issue]>) -> Void
    static func repoIssues(owner: String, repo: String) -> (Int, @escaping IssueResponsesHandler) -> Void {
        
        return { (page: Int, handler: @escaping IssueResponsesHandler) in
            let parameters: Parameters = ["page": page, "state": "all"]
            Alamofire.request(Router.repoIssues(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({ (json: JSON) -> [Model.Issue] in
                    return json.arrayValue.map{
                        Model.Issue(json: $0)
                    }
                })
                handler(result)
            }
        } 
    }
    
    typealias CommentResponsesHandler = (DataResponse<[Model.Comment]>) -> Void
    
    static func issueComment(owner: String, repo: String, number: Int) -> (Int, @escaping CommentResponsesHandler) -> Void {
        return { page, handler in
            let parameters: Parameters = ["page": page]
            Alamofire.request(Router.issueDetail(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({ (json: JSON) -> [Model.Comment] in
                    return json.arrayValue.map{
                        Model.Comment(json: $0)
                    }
                })
                handler(result)
            }
        }
    }
    
    static func issueDetail(owner: String, repo: String, number: Int, page: Int, completionHandler: @escaping (DataResponse<[Model.Comment]>) -> Void) {
        let parameters: Parameters = ["page": page]
        Alamofire.request(Router.issueDetail(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> [Model.Comment] in
                return json.arrayValue.map{
                    Model.Comment(json: $0)
                }
            })
            completionHandler(result)
        }
    }
    
    static func createComment(owner: String, repo: String, number: Int, comment: String, completionHandler: @escaping (DataResponse<Model.Comment>) -> Void ) {
        let parameters: Parameters = ["body": comment]
        Alamofire.request(Router.createComment(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Comment in
                Model.Comment(json: json)
            })
            completionHandler(result)
        }
    }
    
    static func createIssue(owner: String, repo: String, title: String, body: String, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void ) {
        let parameters: Parameters = ["title": title, "body": body]
        Alamofire.request(Router.createIssue(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            print(dataResponse.request?.url?.absoluteString)
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }
    
    static func closeIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.closed.display
        Alamofire.request(Router.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            print(dataResponse.request?.url?.absoluteString)
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
        
    }
    
    static func openIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.open.display
        Alamofire.request(Router.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            print(dataResponse.request?.url?.absoluteString)
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
        
    }
}
