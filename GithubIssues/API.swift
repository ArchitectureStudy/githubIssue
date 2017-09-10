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
        let parameters: Parameters = ["page": page]
        Alamofire.request(Router.repoIssues(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> [Model.Issue] in
                return json.arrayValue.map{
                    Model.Issue(json: $0)
                }
            })
            completionHandler(result)
        }
    }
}
