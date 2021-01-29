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
    static func getUsersList1(completionHandler: @escaping (_ result: Result<UserResponse<[User]>, [String:Any]>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue
        return sendRequest(path: path, completionHandler: completionHandler)
    }

    @discardableResult
    static func getUsersList2(completionHandler: @escaping (_ result: Swift.Result<UserResponse<[User]>, Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue
        return sendRequest(path: path, completionHandler: completionHandler)
    }

    @discardableResult
    static func getUsersList3(completionHandler: @escaping (_ result: Swift.Result<[String:Any], Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue
        return sendRequest(path: path, completionHandler: completionHandler)
    }
}
