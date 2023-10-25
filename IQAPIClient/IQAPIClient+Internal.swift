//
//  IQAPIClient+Internal.swift
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

import UIKit
import Alamofire

internal extension IQAPIClient {

    private struct RequestCounter {
        static var counter: Int = 0
    }

    // swiftlint:disable line_length
    // swiftlint:disable identifier_name
    @discardableResult func _sendRequest<Success, Failure>(url: URLConvertible,
                                                           method: HTTPMethod = .get,
                                                           parameters: Parameters? = nil,
                                                           encoding: ParameterEncoding? = nil,
                                                           headers: HTTPHeaders? = nil,
                                                           forceMultipart: Bool = false,
                                                           completionHandler: @Sendable @escaping (_ originalResponse: AFDataResponse<Data>, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        RequestCounter.counter += 1

        var httpHeaders: HTTPHeaders = self.httpHeaders

        if let headers = headers {
            for header in headers {
                httpHeaders.add(header)
            }
        }

        let requestNumber = RequestCounter.counter
        printRequestURL(url: url, method: method, headers: httpHeaders,
                        parameters: parameters, requestNumber: requestNumber)

        let isMultipart = Self.containsAnyFile(parameters: parameters)

        let request: DataRequest

        if isMultipart || forceMultipart {
            request = session.upload(multipartFormData: { (multipartFormData) in
                if let parameters = parameters {
                    Self.addToMultipartFormData(multipartFormData, fromKey: "", parameters: parameters)
                }
            }, to: url, method: method, headers: httpHeaders)
        } else {

            let finalEncoding: ParameterEncoding
            if let encoding = encoding {
                finalEncoding = encoding
            } else {
                finalEncoding = (method == .get ? URLEncoding.default : JSONEncoding.default)
            }

            request = session.request(url, method: method, parameters: parameters,
                                      encoding: finalEncoding, headers: httpHeaders)
        }
        request.responseData(queue: responseQueue, completionHandler: { (response) in
            self.handleResponse(response: response, requestNumber: requestNumber, completionHandler: completionHandler)
        })
        return request
    }

    @discardableResult func _sendRequest<Success, Failure, Parameters: Encodable>(url: URLConvertible,
                                                                                  method: HTTPMethod = .get,
                                                                                  parameters: Parameters? = nil,
                                                                                  encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                                                                  headers: HTTPHeaders? = nil,
                                                                                  forceMultipart: Bool = false,
                                                                                  completionHandler: @Sendable @escaping (_ originalResponse: AFDataResponse<Data>, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        RequestCounter.counter += 1

        var httpHeaders: HTTPHeaders = self.httpHeaders

        if let headers = headers {
            for header in headers {
                httpHeaders.add(header)
            }
        }

        let requestNumber = RequestCounter.counter
        printRequestURL(url: url, method: method, headers: httpHeaders,
                        parameters: parameters, requestNumber: requestNumber)

        let isMultipart = Self.containsAnyFile(parameters: parameters)

        let request: DataRequest

        if isMultipart || forceMultipart {
            request = session.upload(multipartFormData: { (multipartFormData) in
                if let parameters = parameters {
                    Self.addToMultipartFormData(multipartFormData, fromKey: "", parameters: parameters)
                }
            }, to: url, method: method, headers: httpHeaders)
        } else {

            request = session.request(url, method: method, parameters: parameters, encoder: encoder, headers: httpHeaders)
        }
        request.responseData(queue: responseQueue, completionHandler: { (response) in
            self.handleResponse(response: response, requestNumber: requestNumber, completionHandler: completionHandler)
        })

        return request
    }

    private func handleResponse<Success, Failure>(response: AFDataResponse<Data>,
                                                  requestNumber: Int,
                                                  completionHandler: @Sendable @escaping (_ originalResponse: AFDataResponse<Data>, _ result: IQAPIClient.Result<Success, Failure>) -> Void) {
        printResponse(response: response, requestNumber: requestNumber)

        switch response.result {
        case .success(let data):    /// Successfully got data response from server
            let result: IQAPIClient.Result<Success, Failure> = intercept(response: response, data: data)
            completionHandler(response, result)
        case .failure(let error):   /// Error from the Alamofire
            completionHandler(response, .error(error))
        }
    }

    private static func containsAnyFile(parameters: Any?) -> Bool {

        switch parameters {
        case let array as [Any]:

            for object in array where self.containsAnyFile(parameters: object) {
                return true
            }

            return false

        case let dictionary as [String: Any]:

            for object in dictionary.values where self.containsAnyFile(parameters: object) {
                return true
            }

            return false
        case _ as File:
            return true
        default:
            return false
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private static func addToMultipartFormData(_ multipartFormData: MultipartFormData, fromKey key: String, parameters: Any) {

        switch parameters {
        case let array as [Any]:

            for (index, object) in array.enumerated() {
                if key.isEmpty {
                    addToMultipartFormData(multipartFormData, fromKey: "[\(index)]", parameters: object)
                } else {
                    addToMultipartFormData(multipartFormData, fromKey: "\(key)[\(index)]", parameters: object)
                }
            }

        case let dictionary as [String: Any]:

            for object in dictionary {
                if key.isEmpty {
                    addToMultipartFormData(multipartFormData, fromKey: object.key, parameters: object.value)
                } else {
                    addToMultipartFormData(multipartFormData, fromKey: "\(key)[\(object.key)]", parameters: object.value)
                }
            }

        case let file as File:

            if let url = file.fileURL {
                multipartFormData.append(url, withName: key, fileName: file.fileName, mimeType: file.mimeType)
            } else if let data = file.data {
                multipartFormData.append(data, withName: key, fileName: file.fileName, mimeType: file.mimeType)
            }
        case let data as Data:
            multipartFormData.append(data,
                                     withName: key)
        default:
            if let data = "\(parameters)".data(using: String.Encoding.utf8) {
                multipartFormData.append(data, withName: key)
            } else {
                print("Failed to encode \(key) = \(parameters)")
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
