//
//  IQAPIClient+Debug.swift
//  IQAPIClient
//
//  Created by Iftekhar on 10/09/20.
//

import Foundation
import Alamofire

//MARK: - Debugging -

internal extension IQAPIClient {

    static func printRequestURL(url : URLConvertible, method:HTTPMethod, headers:HTTPHeaders?, parameters : [String : Any]?, requestNumber:Int) {
        if debuggingEnabled {
            print("\n(\(requestNumber)). Request Start \(method.rawValue): \(url) ------------------------")

            if let headers = headers {
                print("(\(requestNumber)). Headers:\(headers)")
            }

            var param = [String: Any]()

            for (key, value) in parameters ?? [:] {
                if let file = value as? UploadableFile {
                    var fileAttributes : [String : Any] = ["name": file.fileName, "type" : file.mimeType, "size": file.data.count]
                    fileAttributes["url"] = file.fileURL?.absoluteString
                    param[key] = fileAttributes
                } else {
                    param[key] = value
                }
            }

            if let jsonString = parameters?.jsonString {
                print("(\(requestNumber)). \(jsonString)")
            }

            print("(\(requestNumber)). Request End------------------------\n")
        }
    }

    static func printResponse(url : URLConvertible, response : AFDataResponse<Data>, requestNumber:Int) {
        if debuggingEnabled {
            print("\n(\(requestNumber)). Response Start \(response.request?.httpMethod ?? "GET"): \(url) ------------------------")

            if let header = response.response {
                print("(\(requestNumber)). StatusCode: \(header.statusCode)")
                print("(\(requestNumber)). Headers:\(header.allHeaderFields)")
            }

            switch response.result {
            case .success(let data):

                if let jsonString = data.jsonString {
                    print("(\(requestNumber)). \(jsonString)")
                } else if let jsonString = data.string {
                    print("(\(requestNumber)). \(jsonString)")
                } else {
                    print("(\(requestNumber)). Unable to convert response to string")
                }
            case .failure(let error):

                if let jsonString = response.data?.string {
                    print("(\(requestNumber)). \(jsonString)")
                }

                print("(\(requestNumber)). \(error)")
            }

            print("(\(requestNumber)). Response End ------------------------\n")
        }
    }
}

