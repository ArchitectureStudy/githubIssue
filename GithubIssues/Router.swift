//
//  Router.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 9..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum Router {
    case authKey(Parameters, HTTPHeaders)
    case repoIssues(owner: String, repo: String, parameters: Parameters)
    
}

extension Router: URLRequestConvertible {
    
    static let baseURLString = "https://api.github.com"
    static let clientID = "36c48adc3d1433fbd286"
    static let clientSecret = "a911bfd178a79f25d14c858a1199cd76d9e92f3b"
    
    var method: HTTPMethod {
        switch self {
        case .authKey:
            return .put
        case .repoIssues:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .authKey:
            return "/authorizations/clients/\(Router.clientID)/\(Date().timeIntervalSince1970)"
        case let .repoIssues(owner, repo, _):
            return "/repos/\(owner)/\(repo)/issues"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        if let token = GlobalState.instance.token, !token.isEmpty {
            urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }

        switch self {
        case let .authKey(parameters, headers):
            headers.forEach{ (key, value) in urlRequest.addValue(value, forHTTPHeaderField: key) }
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case let .repoIssues(_, _, parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}



