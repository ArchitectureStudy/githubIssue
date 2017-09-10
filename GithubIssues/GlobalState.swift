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
    
    
    struct constants {
        static let tokenKey       = "token"
        static let ownerKey      = "owner"
        static let repoKey        = "repo"
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
    
    var isLoggedIn: Bool {
        get {
            let isEmpty = token?.isEmpty ?? true
            return !isEmpty
        }
    }
}
