//
//  GlobalState.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation

final class GlobalState {
    static let instance = GlobalState()
    
    enum ServiceType: String {
        case github
        case bitbucket
    }
    
    struct constants {
        static let tokenKey         = "token"
        static let ownerKey         = "owner"
        static let repoKey          = "repo"
        static let reposKey         = "repos"
        static let serviceType      = "serviceType"
        static let refreshTokenKey   = "refreshToken"
    }
    
    var token: String? {
        get {
            let token = UserDefaults.standard.string(forKey: constants.tokenKey)
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: constants.tokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            let token = UserDefaults.standard.string(forKey: constants.refreshTokenKey)
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: constants.refreshTokenKey)
        }
    }
    
    var owner: String {
        get {
            let owner = UserDefaults.standard.string(forKey: constants.ownerKey) ?? ""
            return owner
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: constants.ownerKey)
        }
    }
    
    var repo: String {
        get {
            let repo = UserDefaults.standard.string(forKey: constants.repoKey) ?? ""
            return repo
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: constants.repoKey)
        }
    }
    
    var serviceType: ServiceType {
        get {
            let type = UserDefaults.standard.string(forKey: constants.serviceType) ?? ""
            let serviceType = ServiceType(rawValue: type) ?? ServiceType.github
            return serviceType
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: constants.serviceType)
        }
    }
    
    var isLoggedIn: Bool {
        get {
            let isEmpty = token?.isEmpty ?? true
            return !isEmpty
        }
    }
    
    func addRepo(owner:String, repo: String) {
        let dict = ["owner": owner, "repo" : repo]
        var repos: [[String: String]] = (UserDefaults.standard.array(forKey: constants.reposKey) as? [[String : String]]) ?? []
        repos.append(dict)
        
        UserDefaults.standard.set(NSSet(array: repos).allObjects, forKey: constants.reposKey)
    }
    
    var repos: [(owner: String, repo:String)] {
        get {
            let repoDicts: [[String: String]] = (UserDefaults.standard.array(forKey: constants.reposKey) as? [[String : String]]) ?? []
            let repos = repoDicts.map { (repoDict: [String: String]) -> (String, String) in
                let owner = repoDict["owner"] ?? ""
                let repo = repoDict["repo"] ?? ""
                return (owner, repo)
            }
            return repos
        }
    }
}
