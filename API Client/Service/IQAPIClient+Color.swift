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
    func colors(completionHandler: @escaping (_ result: Swift.Result<[Color], Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.colors.rawValue

        let request = sendRequest(path: path, completionHandler: completionHandler).validate { _, response, _ in
            if response.statusCode == 401 {
                let error = NSError(domain: "Domain", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Not found"])
                return Request.ValidationResult.failure(error)
            } else {
                return Request.ValidationResult.success(())
            }
        }

        return request
    }

    @discardableResult
    func color(id: Int, completionHandler: @escaping (_ result: Swift.Result<Color, Error>) -> Void) -> DataRequest {
        let path = ITAPIPath.colors.rawValue + "/\(id)"
        return sendRequest(path: path, completionHandler: completionHandler)
    }
}
