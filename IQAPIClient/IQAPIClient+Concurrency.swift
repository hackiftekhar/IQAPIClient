//
//  IQAPIClient.swift
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

#if compiler(>=5.6.0) && canImport(_Concurrency)

import UIKit
import Alamofire

@available(iOS 13, *)
extension IQAPIClient {

    // swiftlint:disable line_length
    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success: Sendable>(path: String,
                                                                  method: HTTPMethod = .get,
                                                                  parameters: Parameters? = nil,
                                                                  encoding: ParameterEncoding? = nil,
                                                                  headers: HTTPHeaders? = nil,
                                                                  successSound: Bool = false,
                                                                  failedSound: Bool = false,
                                                                  forceMultipart: Bool = false,
                                                                  executeErrorHandlerOnError: Bool = true) async throws -> Success {

        guard let baseURL = baseURL else { fatalError("baseURL is not specified.") }

        let result: (request: DataRequest, result: IQAPIClient.Result<Success, Error>)
        result = try await _sendRequest(url: baseURL.appendingPathComponent(path), method: method, parameters: parameters, encoding: encoding, forceMultipart: forceMultipart, headers: headers)

        switch result.result {
        case .success(let response):
            if successSound {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.success)
            }
            return response
        case .failure(let response):
            if failedSound {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.success)
            }

            if executeErrorHandlerOnError {
                commonErrorHandlerBlock?(result.request.request!, parameters, result.request.data, response)
            }

            throw response
        case .error(let error):
            if failedSound {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.error)
            }

            if executeErrorHandlerOnError {
                commonErrorHandlerBlock?(result.request.request!, parameters, result.request.data, error)
            }

            throw error
        }
    }
}

/// internal
@available(iOS 13, *)
internal extension IQAPIClient {

    private struct RequestCounter {
        static var counter: Int = 0
    }

    // swiftlint:disable cyclomatic_complexity
    private func _sendRequest<Success: Sendable, Failure: Sendable>(url: URLConvertible,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoding: ParameterEncoding? = nil,
                                                                    forceMultipart: Bool = false,
                                                                    headers: HTTPHeaders? = nil) async throws -> (request: DataRequest, result: IQAPIClient.Result<Success, Failure>) {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        RequestCounter.counter += 1

        var httpHeaders: HTTPHeaders

        if let headers = headers {
            httpHeaders = headers

            for header in self.httpHeaders {
                httpHeaders.add(header)
            }
        } else {
            httpHeaders = self.httpHeaders
        }

        let requestNumber = RequestCounter.counter
        await printRequestURL(url: url, method: method, headers: httpHeaders,
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

            request = session.request(url, method: method, parameters: parameters, encoding: finalEncoding, headers: httpHeaders)
        }

        let response = await request.serializingData().response
        async let result = response.result
        await printResponse(response: response, requestNumber: requestNumber)

        switch await result {
        case .success(let data):    /// Successfully got data response from server
            let result: IQAPIClient.Result<Success, Failure> = intercept(response: response, data: data)

            switch result {
            case .success, .failure:
                return (request, result)
            case .error(let error):
                throw error
            }
        case .failure(let error):   /// Error from the Alamofire
            throw error
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
            multipartFormData.append(data, withName: key)
        default:
            if let data = "\(parameters)".data(using: String.Encoding.utf8) {
                multipartFormData.append(data, withName: key)
            } else {
                print("Failed to encode \(key) = \(parameters)")
            }
        }
    }
}

#endif
