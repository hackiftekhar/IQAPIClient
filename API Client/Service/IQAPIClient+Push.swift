//
//  ITAPIClient+APNS.swift
//  Institute
//
//  Created by Iftekhar on 01/06/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import IQAPIClient
import Alamofire

// MARK: - Push Notifications -

extension IQAPIClient {

    @discardableResult
    static func registerDevice(_ attributes: [String: Any], completionHandler: @escaping (_ result: Swift.Result<APIMessage, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.push_register.rawValue
        return sendRequest(path: path, method: .post, parameters: attributes, successSound: false, completionHandler: completionHandler)
    }

    @discardableResult
    static func unregisterDevice(completionHandler: @escaping (_ result: Swift.Result<APIMessage, NSError>) -> Void) -> DataRequest {
        let path = ITAPIPath.push_register.rawValue
        return sendRequest(path: path, method: .post, successSound: false, completionHandler: completionHandler)
    }
}
