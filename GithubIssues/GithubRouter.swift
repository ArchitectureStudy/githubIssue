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

enum GithubRouter  {
    case authKey(Parameters, HTTPHeaders)
    case repoIssues(owner: String, repo: String, parameters: Parameters)
    case issueDetail(owner: String, repo: String, number: Int, parameters: Parameters)
    case createComment(owner: String, repo: String, number: Int, parameters: Parameters)
    case createIssue(owner: String, repo: String, parameters: Parameters)
    case editIssue(owner: String, repo: String, number: Int, parameters: Parameters)
}

extension GithubRouter: URLRequestConvertible {
    static let baseURLString: String = "https://api.github.com"
    static let clientID: String = "36c48adc3d1433fbd286"
    static let clientSecret: String = "a911bfd178a79f25d14c858a1199cd76d9e92f3b"
    
    var method: HTTPMethod {
        switch self {
        case .authKey:
            return .put
        case .repoIssues,
             .issueDetail
            :
            return .get
        case .createComment,
             .createIssue
            :
            return .post
        case .editIssue
            :
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .authKey:
            return "/authorizations/clients/\(GithubRouter.clientID)/\(Date().timeIntervalSince1970)"
        case let .repoIssues(owner, repo, _):
            return "/repos/\(owner)/\(repo)/issues"
        case let .issueDetail(owner, repo, number, _):
            return "/repos/\(owner)/\(repo)/issues/\(number)/comments"
        case let .createComment(owner, repo, number, _):
            return "/repos/\(owner)/\(repo)/issues/\(number)/comments"
        case let .createIssue(owner, repo, _):
            return "/repos/\(owner)/\(repo)/issues"
        case let .editIssue(owner, repo, number, _):
            return "/repos/\(owner)/\(repo)/issues/\(number)"
        }
    }
    func asURLRequest() throws -> URLRequest {
        let url = try GithubRouter.baseURLString.asURL()
        
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
        case let .issueDetail(_, _, _, parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case let .createComment(_, _, _, parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case let .createIssue(_, _, parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case let .editIssue(_, _, _, parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}
