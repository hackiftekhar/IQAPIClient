//
//  IQAPIClient+EncodableSendRequest.swift
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

// swiftlint:disable line_length

/// `Success` either be a `valid JSON type` or must conform to `Decodable` protocol
extension IQAPIClient {

    @discardableResult public func sendRequest<Success, Parameters>(path: String,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoder: ParameterEncoder? = nil,
                                                                    headers: HTTPHeaders? = nil,
                                                                    options: Options = [],
                                                                    completionHandler: @Sendable @escaping @MainActor (_ result: Swift.Result<Success, Error>) -> Void) -> DataRequest
    where Success: Sendable, Parameters: Encodable {
        return sendRequest(path: path,
                           method: method,
                           parameters: parameters,
                           encoder: encoder,
                           headers: headers,
                           options: options,
                           completionHandler: { (_, result: Swift.Result<Success, Error>) in
            completionHandler(result)
        })
    }

    /// `Success` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success, Parameters>(path: String,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoder: ParameterEncoder? = nil,
                                                                    headers: HTTPHeaders? = nil,
                                                                    options: Options = [],
                                                                    completionHandler: @Sendable @escaping @MainActor (_ httpURLResponse: HTTPURLResponse, _ result: Swift.Result<Success, Error>) -> Void) -> DataRequest
    where Success: Sendable, Parameters: Encodable {

        guard let baseURL = baseURL else { fatalError("baseURL is not specified.") }

        return sendRequest(url: baseURL.appendingPathComponent(path),
                           method: method,
                           parameters: parameters,
                           encoder: encoder,
                           headers: headers,
                           options: options,
                           completionHandler: { (_ httpURLResponse: HTTPURLResponse, _ result: IQAPIClient.Result<Success, Error>) in

            switch result {
            case .success(let response):
                completionHandler(httpURLResponse, .success(response))
            case .failure(let response):
                completionHandler(httpURLResponse, .failure(response))
            case .error(let error):
                completionHandler(httpURLResponse, .failure(error))
            }
        })
    }
}

extension IQAPIClient {

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success, Failure, Parameters>(path: String,
                                                                             method: HTTPMethod = .get,
                                                                             parameters: Parameters? = nil,
                                                                             encoder: ParameterEncoder? = nil,
                                                                             headers: HTTPHeaders? = nil,
                                                                             options: Options = [],
                                                                             completionHandler: @Sendable @escaping @MainActor (_ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest
    where Success: Sendable, Failure: Sendable, Parameters: Encodable {
        return sendRequest(path: path,
                           method: method,
                           parameters: parameters,
                           encoder: encoder,
                           headers: headers,
                           options: options,
                           completionHandler: { (_, result: IQAPIClient.Result<Success, Failure>) in
            completionHandler(result)
        })
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success, Failure, Parameters>(path: String,
                                                                             method: HTTPMethod = .get,
                                                                             parameters: Parameters? = nil,
                                                                             encoder: ParameterEncoder? = nil,
                                                                             headers: HTTPHeaders? = nil,
                                                                             options: Options = [],
                                                                             completionHandler: @Sendable @escaping @MainActor (_ httpURLResponse: HTTPURLResponse, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest
    where Success: Sendable, Failure: Sendable, Parameters: Encodable {

        guard let baseURL = baseURL else { fatalError("baseURL is not specified.") }

        return _sendRequest(url: baseURL.appendingPathComponent(path),
                            method: method,
                            parameters: parameters,
                            encoder: encoder,
                            headers: headers,
                            options: options,
                            completionHandler: { (originalResponse: AFDataResponse, result: IQAPIClient.Result<Success, Failure>) in
            
            completionHandler(originalResponse.response ?? HTTPURLResponse(), result)
        })
    }
}
// swiftlint:enable line_length
