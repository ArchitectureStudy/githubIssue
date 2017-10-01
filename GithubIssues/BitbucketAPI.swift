//  BitbucketAPI.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 30..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import OAuthSwift

struct BitbucketAPI: API {
    let bitbucketOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "vx2MD5uVaRyLgMxype",
        consumerSecret: "CA9cZxqWEgRDpZCCYy353WG763J8McWH",
        authorizeUrl:   "https://bitbucket.org/site/oauth2/authorize",
        accessTokenUrl: "https://bitbucket.org/site/oauth2/access_token",
        responseType:   "code"
    )
    func getOauthKey(user: String, password: String, completionHandler: @escaping (DataResponse<JSON>) -> Void) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        let parameters: Parameters = ["client_secret": BitbucketRouter.clientSecret , "scopes": ["public_repo"], "note": "admin script" ]
        Alamofire.request(BitbucketRouter.authKey(parameters, headers))
            .responseSwiftyJSON { json in
                print(json)
                completionHandler(json)
        }
    }
    func getToekn(handler: @escaping (() -> Void)) {
        guard let url = URL(string:"ISSAPP://oauth-callback/bitbucket") else { return }
        bitbucketOAuth.authorize(
            withCallbackURL: url,
            scope: "issue:write", state:"state",
            success: {(credential, _, _) in
                GlobalState.instance.token = credential.oauthToken
                GlobalState.instance.refreshToken = credential.oauthRefreshToken
                GlobalState.instance.serviceType = .bitbucket
                App.api = BitbucketAPI()
                handler()
        }, failure: { ( error ) in
            print(error.localizedDescription)
        })
    }
    func tokenRefresh(handler: @escaping (() -> Void)) {
        guard let refreshToken = GlobalState.instance.refreshToken else { return }
        bitbucketOAuth.renewAccessToken(
            withRefreshToken: refreshToken,
            success: { (credential, _, _) in
            GlobalState.instance.token = credential.oauthToken
            GlobalState.instance.refreshToken = credential.oauthRefreshToken
            GlobalState.instance.serviceType = .bitbucket
            App.api = BitbucketAPI()
            handler()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
    }
    func repoIssues(owner: String, repo: String) -> (Int, @escaping IssueResponsesHandler) -> Void {
        return { (page: Int, handler: @escaping IssueResponsesHandler) in
            let parameters: Parameters = ["page": page, "state": "all"]
            Alamofire.request(BitbucketRouter.repoIssues(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                if dataResponse.response?.statusCode == 401 {
                    var retryCount = 1
                    self.tokenRefresh {
                        if retryCount > 1 {
                            return
                        }
                        retryCount += 1
                        self.repoIssues(owner: owner, repo: repo)(page, handler)
                    }
                    return
                }
                let result = dataResponse.map({ (json: JSON) -> [Model.Issue] in
                    return json["values"].arrayValue.map { (json: JSON) -> Model.Issue in
                        Model.Issue(json: json.githubIssueToBitbucket)
                    }
                })
                handler(result)
            }
        }
    }
    func issueComment(owner: String, repo: String, number: Int) -> (Int, @escaping CommentResponsesHandler) -> Void {
        return { page, handler in
            let parameters: Parameters = ["page": page]
            Alamofire.request(BitbucketRouter.issueDetail(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({ (json: JSON) -> [Model.Comment] in
                    return json["values"].arrayValue.map {
                        Model.Comment(json: $0.githubCommentToBitbucket)
                    }
                })
                handler(result)
            }
        }
    }
    func createComment(owner: String, repo: String, number: Int, comment: String, completionHandler: @escaping (DataResponse<Model.Comment>) -> Void ) {
        let parameters: Parameters = ["body": comment]
        Alamofire.request(BitbucketRouter.createComment(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Comment in
                Model.Comment(json: json)
            })
            completionHandler(result)
        }
    }
    func createIssue(owner: String, repo: String, title: String, body: String, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void ) {
        let parameters: Parameters = ["title": title, "content": ["raw":body]]
        Alamofire.request(BitbucketRouter.createIssue(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json.githubIssueToBitbucket)
            })
            completionHandler(result)
        }
    }
    func closeIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.closed.display
        Alamofire.request(BitbucketRouter.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }
    func openIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.open.display
        Alamofire.request(BitbucketRouter.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }

}

extension JSON {
    /*
     
     id -> id
     number -> id
     title -> title
     comments ->
     body -> [content][raw]
     createdAt -> created_on
     closedAt ->  state, new -> open, closed -> closed

     */
    var githubIssueToBitbucket: JSON {
        var json = JSON()
        json["id"] = self["id"]
        json["number"] = self["id"]
        json["title"] = self["title"]
        json["body"] = self["content"]["raw"]
        json["user"] = self["reporter"].githubUserToBitbucket
        switch self["state"].stringValue {
        case "new":
            json["state"].string = "open"
        case "closed":
            json["state"].string = "closed"
        default:
            json["state"].string = "none"
        }
        let created_at = (self["created_on"].stringValue.components(separatedBy: ".").first ?? "")+"Z"
        json["created_at"].string = created_at
        return json
    }
    /*id -> uuid
     login -> username
     avatar_url -> ["links"]["avatar"]["href"]*/
    var githubUserToBitbucket: JSON {
        var json = JSON()
        json["id"] = self["uuid"]
        json["login"] = self["username"]
        json["avatar_url"] = self["links"]["avatar"]["href"]
        return json
    }
    /*
     id -> id
     user -> user.git
     body -> ["content"]["raw"]
     createdAt -> created_on
     updatedAt -> updated_on
     */
    var githubCommentToBitbucket: JSON {
        var json = JSON()
        json["id"] = self["id"]
        json["user"] = self["user"].githubUserToBitbucket
        json["body"] = self["content"]["raw"]
        let createdAt = (self["created_on"].stringValue.components(separatedBy: ".").first ?? "")+"Z"
        json["created_at"].string = createdAt
        let updatedAt = (self["updated_at"].stringValue.components(separatedBy: ".").first ?? "")+"Z"
        json["updated_at"].string = updatedAt
        return json
    }
}
