//  IQAPIClient+SendRequest.swift
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

/*
 These 4 types of completion blocks supported

 1) result: Swift.Result<Success, Error>
 2) result: IQAPIClient.Result<Success, Failure>
 3) httpURLResponse: HTTPURLResponse?, _ result: Swift.Result<Success, Error>
 4) httpURLResponse: HTTPURLResponse?, _ result: IQAPIClient.Result<Success, Failure>
 */

// swiftlint:disable line_length
extension IQAPIClient {

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success>(path: String,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoding: ParameterEncoding? = nil,
                                                        headers: HTTPHeaders? = nil,
                                                        successSound: Bool = false,
                                                        failedSound: Bool = false,
                                                        executeErrorHandlerOnError: Bool = true,
                                                        forceMultipart: Bool = false,
                                                        completionHandler: @escaping (_ result: Swift.Result<Success, Error>) -> Void) -> DataRequest {

        return sendRequest(path: path,
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart,
                           completionHandler: { (_, result: Swift.Result<Success, Error>) in
            completionHandler(result)
        })
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success>(path: String,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoding: ParameterEncoding? = nil,
                                                        headers: HTTPHeaders? = nil,
                                                        successSound: Bool = false,
                                                        failedSound: Bool = false,
                                                        executeErrorHandlerOnError: Bool = true,
                                                        forceMultipart: Bool = false,
                                                        completionHandler: @escaping (_ httpURLResponse: HTTPURLResponse?, _ result: Swift.Result<Success, Error>) -> Void) -> DataRequest {

        guard let baseURL = baseURL else { fatalError("basseURL is not specified.") }

        return sendRequest(url: baseURL.appendingPathComponent(path),
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart,
                           completionHandler: { (httpURLResponse: HTTPURLResponse?, result: IQAPIClient.Result<Success, Error>) in
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
    @discardableResult public func sendRequest<Success, Failure>(path: String,
                                                                 method: HTTPMethod = .get,
                                                                 parameters: Parameters? = nil,
                                                                 encoding: ParameterEncoding? = nil,
                                                                 headers: HTTPHeaders? = nil,
                                                                 successSound: Bool = false,
                                                                 failedSound: Bool = false,
                                                                 executeErrorHandlerOnError: Bool = true,
                                                                 forceMultipart: Bool = false,
                                                                 completionHandler: @escaping (_ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {
        return sendRequest(path: path,
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart,
                           completionHandler: { (_, result: IQAPIClient.Result<Success, Failure>) in
            completionHandler(result)
        })
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success, Failure>(path: String,
                                                                 method: HTTPMethod = .get,
                                                                 parameters: Parameters? = nil,
                                                                 encoding: ParameterEncoding? = nil,
                                                                 headers: HTTPHeaders? = nil,
                                                                 successSound: Bool = false,
                                                                 failedSound: Bool = false,
                                                                 executeErrorHandlerOnError: Bool = true,
                                                                 forceMultipart: Bool = false,
                                                                 completionHandler: @escaping (_ httpURLResponse: HTTPURLResponse?, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {
        guard let baseURL = baseURL else { fatalError("basseURL is not specified.") }

        return sendRequest(url: baseURL.appendingPathComponent(path),
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart, completionHandler: completionHandler)
    }
}

extension IQAPIClient {

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success>(url: URLConvertible,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoding: ParameterEncoding? = nil,
                                                        headers: HTTPHeaders? = nil,
                                                        successSound: Bool = false,
                                                        failedSound: Bool = false,
                                                        executeErrorHandlerOnError: Bool = true,
                                                        forceMultipart: Bool = false,
                                                        completionHandler: @escaping (_ result: Swift.Result<Success, Error>) -> Void) -> DataRequest {
        return sendRequest(url: url,
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart,
                           completionHandler: { (_, result: Swift.Result<Success, Error>) in
            completionHandler(result)
        })
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success>(url: URLConvertible,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoding: ParameterEncoding? = nil,
                                                        headers: HTTPHeaders? = nil,
                                                        successSound: Bool = false,
                                                        failedSound: Bool = false,
                                                        executeErrorHandlerOnError: Bool = true,
                                                        forceMultipart: Bool = false,
                                                        completionHandler: @escaping (_ httpURLResponse: HTTPURLResponse?, _ result: Swift.Result<Success, Error>) -> Void) -> DataRequest {
        return sendRequest(url: url,
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart,
                           completionHandler: { (_ httpURLResponse: HTTPURLResponse?, _ result: IQAPIClient.Result<Success, Error>) in

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
    @discardableResult public func sendRequest<Success, Failure>(url: URLConvertible,
                                                                 method: HTTPMethod = .get,
                                                                 parameters: Parameters? = nil,
                                                                 encoding: ParameterEncoding? = nil,
                                                                 headers: HTTPHeaders? = nil,
                                                                 successSound: Bool = false,
                                                                 failedSound: Bool = false,
                                                                 executeErrorHandlerOnError: Bool = true,
                                                                 forceMultipart: Bool = false,
                                                                 completionHandler: @escaping (_ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {
        return sendRequest(url: url,
                           method: method,
                           parameters: parameters,
                           encoding: encoding,
                           headers: headers,
                           successSound: successSound,
                           failedSound: failedSound,
                           executeErrorHandlerOnError: executeErrorHandlerOnError,
                           forceMultipart: forceMultipart,
                           completionHandler: { (_, result: IQAPIClient.Result<Success, Failure>) in
            completionHandler(result)
        })
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success, Failure>(url: URLConvertible,
                                                                 method: HTTPMethod = .get,
                                                                 parameters: Parameters? = nil,
                                                                 encoding: ParameterEncoding? = nil,
                                                                 headers: HTTPHeaders? = nil,
                                                                 successSound: Bool = false,
                                                                 failedSound: Bool = false,
                                                                 executeErrorHandlerOnError: Bool = true,
                                                                 forceMultipart: Bool = false,
                                                                 completionHandler: @escaping (_ httpURLResponse: HTTPURLResponse?, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {
        return _sendRequest(url: url,
                            method: method,
                            parameters: parameters,
                            encoding: encoding,
                            headers: headers,
                            forceMultipart: forceMultipart,
                            completionHandler: { (originalResponse: AFDataResponse, result: IQAPIClient.Result<Success, Failure>) in

            OperationQueue.main.addOperation {
                completionHandler(originalResponse.response, result)
            }

            switch result {
            case .success:
                if successSound {
                    Self.haptic.prepare()
                    Self.haptic.notificationOccurred(.success)
                }
            case .failure(let response):
                if failedSound {
                    Self.haptic.prepare()
                    Self.haptic.notificationOccurred(.success)
                }
                if executeErrorHandlerOnError, let response = response as? Error {
                    OperationQueue.main.addOperation {
                        self.commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, response)
                    }
                }
            case .error(let error):
                if failedSound {
                    Self.haptic.prepare()
                    Self.haptic.notificationOccurred(.error)
                }
                if executeErrorHandlerOnError {
                    OperationQueue.main.addOperation {
                        self.commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
            }
        })
    }
}
