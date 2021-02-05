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
    static func users(completionHandler: @escaping (_ result: Swift.Result<[User], Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue
        return sendRequest(path: path, completionHandler: completionHandler)
    }

    @discardableResult
    static func user(id: Int, completionHandler: @escaping (_ result: Swift.Result<User, Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue + "/\(id)"
        return sendRequest(path: path, completionHandler: completionHandler)
    }
}
