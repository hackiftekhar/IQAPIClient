//
//  IQAPIClient+Color.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import IQAPIClient
import Alamofire

extension IQAPIClient {

    @discardableResult
    static func colors(completionHandler: @escaping (_ result: Swift.Result<[Color], Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.colors.rawValue
        return sendRequest(path: path, completionHandler: completionHandler)
    }

    @discardableResult
    static func color(id: Int,
                      completionHandler: @escaping (_ result: Swift.Result<Color, Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.colors.rawValue + "/\(id)"
        return sendRequest(path: path, completionHandler: completionHandler)
    }
}
