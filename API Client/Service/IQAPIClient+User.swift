//
//  ITAPiClient+User.swift
//  Institute
//
//  Created by Iftekhar on 31/05/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import IQAPIClient
import Alamofire

extension IQAPIClient {

    @discardableResult
    static func signUp(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<User, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.register.rawValue
        return sendRequest(path: path, method: .post, parameters: attributes, completionHandler: completionHandler)
    }

    @discardableResult
    static func signIn(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<User, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.session.rawValue
        return sendRequest(path: path, method: .post, parameters: attributes, completionHandler: completionHandler)
    }

    @discardableResult
    static func getUserSession(completionHandler: @escaping (_ result: Swift.Result<User, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.session.rawValue
        return sendRequest(path: path, method: .post, completionHandler: completionHandler)
    }

    @discardableResult
    static func logout(completionHandler: @escaping (_ result: Swift.Result<APIMessage, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.session.rawValue
        return sendRequest(path: path, method: .post, completionHandler: completionHandler)
    }
}

// MARK: - Password -

extension IQAPIClient {

    @discardableResult
    static func forgotPassword(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<APIMessage, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.forgot_password.rawValue
        return sendRequest(path: path, method: .post, parameters: attributes, completionHandler: completionHandler)
    }

    @discardableResult
    static func changePassword(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<APIMessage, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.change_password.rawValue
        return sendRequest(path: path, method: .post, parameters: attributes, completionHandler: completionHandler)
    }
}

// MARK: - Profile -

extension IQAPIClient {

    @discardableResult
    static func getUserProfile(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<User, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.profile.rawValue
        return sendRequest(path: path, method: .get, parameters: attributes, completionHandler: completionHandler)
    }

    @discardableResult
    static func updateUserProfile(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<User, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.profile.rawValue
        return sendRequest(path: path, method: .post, parameters: attributes, completionHandler: completionHandler)
    }
}
