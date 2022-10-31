//
//  IQAPIClient+Debug.swift
//  https://github.com/hackiftekhar/IQAPIClient
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Alamofire

// MARK: - Debugging -

internal extension IQAPIClient {

    private static let logQueue: DispatchQueue = DispatchQueue(label: "com.iqapiclient.logQueue", qos: .background)

    static func printRequestURL(url: URLConvertible, method: HTTPMethod,
                                headers: HTTPHeaders?, parameters: [String: Any]?, requestNumber: Int) {
        if debuggingEnabled {
            logQueue.async {
                print("\n(\(requestNumber)). Request Start \(method.rawValue): \(url) --------")

                if let headers = headers {
                    print("(\(requestNumber)). Headers:\(headers)")
                }

                let parameters = self.convertFileToPrettyString(parameters: parameters) as? [String: Any]

                if let jsonString = parameters?.prettyJsonString {
                    print("(\(requestNumber)). \(jsonString)")
                }

                print("(\(requestNumber)). Request End --------\n")
            }
        }
    }

    static func printResponse(url: URLConvertible, response: AFDataResponse<Data>, requestNumber: Int) {
        if debuggingEnabled {
            logQueue.async {
                print("\n(\(requestNumber)). Response Start \(response.request?.httpMethod ?? "GET"): \(url) --------")

                if let header = response.response {
                    print("(\(requestNumber)). StatusCode: \(header.statusCode)")
                    print("(\(requestNumber)). Headers:\(header.allHeaderFields)")
                }

                switch response.result {
                case .success(let data):

                    if let jsonString = data.prettyJsonString {
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

                print("(\(requestNumber)). Response End --------\n")
            }
        }
    }

#if compiler(>=5.6.0) && canImport(_Concurrency)
    @available(iOS 13.0.0, *)
    static func printRequestURL(url: URLConvertible, method: HTTPMethod,
                                headers: HTTPHeaders?, parameters: [String: Any]?, requestNumber: Int) async {
        if debuggingEnabled {
            print("\n(\(requestNumber)). Request Start \(method.rawValue): \(url) --------")

            if let headers = headers {
                print("(\(requestNumber)). Headers:\(headers)")
            }

            let parameters = self.convertFileToPrettyString(parameters: parameters) as? [String: Any]

            if let jsonString = parameters?.prettyJsonString {
                print("(\(requestNumber)). \(jsonString)")
            }

            print("(\(requestNumber)). Request End --------\n")
        }
    }

    @available(iOS 13.0.0, *)
    static func printResponse(url: URLConvertible, response: AFDataResponse<Data>, requestNumber: Int) async {
        if debuggingEnabled {
            print("\n(\(requestNumber)). Response Start \(response.request?.httpMethod ?? "GET"): \(url) --------")

            if let header = response.response {
                print("(\(requestNumber)). StatusCode: \(header.statusCode)")
                print("(\(requestNumber)). Headers:\(header.allHeaderFields)")
            }

            switch response.result {
            case .success(let data):

                if let jsonString = data.prettyJsonString {
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

            print("(\(requestNumber)). Response End --------\n")
        }
    }
#endif

    private static func convertFileToPrettyString(parameters: Any?) -> Any? {

        switch parameters {
        case var array as [Any]:
            for (index, object) in array.enumerated() {
                if let object = self.convertFileToPrettyString(parameters: object) {
                    array[index] = object
                }
            }

            return array

        case var dictionary as [String: Any]:

            for (key, object) in dictionary {
                dictionary[key] = self.convertFileToPrettyString(parameters: object)
            }

            return dictionary
        case let file as File:
            return file.description
        default:
            return parameters
        }
    }
}
