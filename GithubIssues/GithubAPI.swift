//
//  GithubAPI.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 30..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import OAuthSwift

struct GithubAPI: API {
    let githubOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "36c48adc3d1433fbd286",
        consumerSecret: "a911bfd178a79f25d14c858a1199cd76d9e92f3b",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType:   "code"
    )

    func getOauthKey(user: String, password: String, completionHandler: @escaping (DataResponse<JSON>) -> Void) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        let parameters: Parameters = ["client_secret": GithubRouter.clientSecret , "scopes": ["public_repo"], "note": "admin script" ]
        Alamofire.request(GithubRouter.authKey(parameters, headers))
            .responseSwiftyJSON { json in
                print(json)
                completionHandler(json)
        }
    }
    func getToekn(handler: @escaping (() -> Void)) {
        githubOAuth.authorize(
            withCallbackURL: URL(string: "ISSAPP://oauth-callback/github")!,
            scope: "user,repo", state:"state",
            success: { credential, _, _ in
                GlobalState.instance.token = credential.oauthToken
                GlobalState.instance.serviceType = .github
                App.api = GithubAPI()
                handler()
            },
            failure: { error in
                print(error.localizedDescription)
        })
    }
    func tokenRefresh(handler: @escaping (() -> Void)) {
        guard let refreshToken = GlobalState.instance.refreshToken else { return }
        githubOAuth.renewAccessToken(withRefreshToken: refreshToken, success: { (credential, _, _) in
            GlobalState.instance.token = credential.oauthToken
            GlobalState.instance.serviceType = .github
            App.api = GithubAPI()
            handler()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
    }
    
    func repoIssues(owner: String, repo: String) -> (Int, @escaping IssueResponsesHandler) -> Void {
        return { (page: Int, handler: @escaping IssueResponsesHandler) in
            let parameters: Parameters = ["page": page, "state": "all"]
            Alamofire.request(GithubRouter.repoIssues(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({ (json: JSON) -> [Model.Issue] in
                    return json.arrayValue.map {
                        Model.Issue(json: $0)
                    }
                })
                handler(result)
            }
        }
    }
    
    func issueComment(owner: String, repo: String, number: Int) -> (Int, @escaping CommentResponsesHandler) -> Void {
        return { page, handler in
            let parameters: Parameters = ["page": page]
            Alamofire.request(GithubRouter.issueDetail(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({ (json: JSON) -> [Model.Comment] in
                    return json.arrayValue.map {
                        Model.Comment(json: $0)
                    }
                })
                handler(result)
            }
        }
    }
    
    func createComment(owner: String, repo: String, number: Int, comment: String, completionHandler: @escaping (DataResponse<Model.Comment>) -> Void ) {
        let parameters: Parameters = ["body": comment]
        Alamofire.request(GithubRouter.createComment(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Comment in
                Model.Comment(json: json)
            })
            completionHandler(result)
        }
    }
    
    func createIssue(owner: String, repo: String, title: String, body: String, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void ) {
        let parameters: Parameters = ["title": title, "body": body]
        Alamofire.request(GithubRouter.createIssue(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }
    
    func closeIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.closed.display
        Alamofire.request(GithubRouter.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
        
    }
    
    func openIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.open.display
        Alamofire.request(GithubRouter.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
        
    }
}
