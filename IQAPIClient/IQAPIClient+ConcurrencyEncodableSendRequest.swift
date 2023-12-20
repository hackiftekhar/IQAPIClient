//
//  IQAPIClient+ConcurrencyEncodableSendRequest.swift
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
extension IQAPIClient {

//    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
//    @discardableResult public func sendRequest<Success, Parameters>(path: String,
//                                                                    method: HTTPMethod = .get,
//                                                                    parameters: Parameters? = nil,
//                                                                    encoder: ParameterEncoder? = nil,
//                                                                    headers: HTTPHeaders? = nil,
//                                                                    options: Options = []) async throws -> Success
//    where Success: Sendable, Parameters: Encodable {
//        let result: (httpResponse: HTTPURLResponse, result: Success)
//        result = try await sendRequest(path: path, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)
//        return result.result
//    }

    /// `Success` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success, Parameters>(path: String,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoder: ParameterEncoder? = nil,
                                                                    headers: HTTPHeaders? = nil,
                                                                    options: Options = []) async throws -> (httpResponse: HTTPURLResponse, result: Success)
    where Success: Sendable, Parameters: Encodable {

        guard let baseURL = baseURL else { fatalError("baseURL is not specified.") }

        let result: (httpResponse: HTTPURLResponse, result: Success)
        result = try await sendRequest(url: baseURL.appendingPathComponent(path), method: method, parameters: parameters, encoder: encoder, headers: headers, options: options)
        return result
    }

//    @discardableResult public func sendRequest<Success, Parameters>(url: URLConvertible,
//                                                                    method: HTTPMethod = .get,
//                                                                    parameters: Parameters? = nil,
//                                                                    encoder: ParameterEncoder? = nil,
//                                                                    headers: HTTPHeaders? = nil,
//                                                                    options: Options = []) async throws -> Success
//    where Success: Sendable, Parameters: Encodable {
//
//        let result: (httpResponse: HTTPURLResponse, result: Success)
//        result = try await sendRequest(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)
//        return result.result
//    }

    @discardableResult public func sendRequest<Success, Parameters>(url: URLConvertible,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoder: ParameterEncoder? = nil,
                                                                    headers: HTTPHeaders? = nil,
                                                                    options: Options = [])  async throws -> (httpResponse: HTTPURLResponse, result: Success)
    where Success: Sendable, Parameters: Encodable {

        let result: (response: DataResponse<Data, AFError>, result: IQAPIClient.Result<Success, Error>)
        result = try await _sendRequest(url: url, method: method, parameters: parameters, encoder: encoder, headers: headers, options: options)

        switch result.result {
        case .success(let response):
            return (result.response.response ?? HTTPURLResponse(), response)
        case .failure(let response):
            throw response
        case .error(let error):
            throw error
        }
    }

}
// swiftlint:enable line_length
