//
//  IQAPIClient+User.swift
//  Institute
//
//  Created by Iftekhar on 31/05/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import IQAPIClient
import Alamofire

extension IQAPIClient {

    @discardableResult
    func users(completionHandler: @Sendable @escaping @MainActor (_ result: Swift.Result<[User], Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue
        return sendRequest(path: path, completionHandler: completionHandler)
    }

    @discardableResult
    func user(id: Int, completionHandler: @Sendable @escaping @MainActor (_ result: IQAPIClient.Result<User, ErrorResponse>) -> Void) -> DataRequest {
        let path = ITAPIPath.users.rawValue + "/\(id)"
        return sendRequest(path: path, completionHandler: completionHandler)
    }

//    @available(iOS 13, *)
//    func asyncAwaitUsers() async throws -> [User] {
//        let path = ITAPIPath.users.rawValue
//        return try await sendRequest(path: path, options: [.successSound, .failedSound]).result
//    }
//
//    @available(iOS 13, *)
//    func asyncAwaituser(id: Int) async throws -> User {
//        let path = ITAPIPath.users.rawValue + "/\(id)"
//        return try await sendRequest(path: path, options: [.successSound, .failedSound]).result
//    }
}
