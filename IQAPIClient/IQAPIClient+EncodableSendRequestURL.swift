//
//  IQAPIClient+EncodableSendRequestURL.swift
//  IQAPIClient
//
//  Created by Iftekhar on 12/19/23.
//

import Foundation
@preconcurrency import Alamofire

// swiftlint:disable line_length

/// `Success` either be a `valid JSON type` or must conform to `Decodable` protocol
extension IQAPIClient {

    @discardableResult public func sendRequest<Success, Parameters>(url: URLConvertible,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoder: ParameterEncoder? = nil,
                                                                    headers: HTTPHeaders? = nil,
                                                                    options: Options = [],
                                                                    completionHandler: @Sendable @escaping @MainActor (_ result: Swift.Result<Success, Error>) -> Void) -> DataRequest
    where Success: Sendable, Parameters: Encodable {
        return sendRequest(url: url,
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
    @discardableResult public func sendRequest<Success, Parameters>(url: URLConvertible,
                                                                    method: HTTPMethod = .get,
                                                                    parameters: Parameters? = nil,
                                                                    encoder: ParameterEncoder? = nil,
                                                                    headers: HTTPHeaders? = nil,
                                                                    options: Options = [],
                                                                    completionHandler: @Sendable @escaping @MainActor (_ httpURLResponse: HTTPURLResponse, _ result: Swift.Result<Success, Error>) -> Void) -> DataRequest
    where Success: Sendable, Parameters: Encodable {
        return sendRequest(url: url,
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
    @discardableResult public func sendRequest<Success, Failure, Parameters>(url: URLConvertible,
                                                                             method: HTTPMethod = .get,
                                                                             parameters: Parameters? = nil,
                                                                             encoder: ParameterEncoder? = nil,
                                                                             headers: HTTPHeaders? = nil,
                                                                             options: Options = [],
                                                                             completionHandler: @Sendable @escaping @MainActor (_ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest
    where Success: Sendable, Failure: Sendable, Parameters: Encodable {
        return sendRequest(url: url,
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
    @discardableResult public func sendRequest<Success, Failure, Parameters>(url: URLConvertible,
                                                                             method: HTTPMethod = .get,
                                                                             parameters: Parameters? = nil,
                                                                             encoder: ParameterEncoder? = nil,
                                                                             headers: HTTPHeaders? = nil,
                                                                             options: Options = [],
                                                                             completionHandler: @Sendable @escaping @MainActor (_ httpURLResponse: HTTPURLResponse, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest
    where Success: Sendable, Failure: Sendable, Parameters: Encodable {
        return _sendRequest(url: url,
                            method: method,
                            parameters: parameters,
                            encoder: encoder,
                            headers: headers,
                            options: options,
                            completionHandler: { (originalResponse: AFDataResponse, result: IQAPIClient.Result<Success, Failure>) in

            DispatchQueue.main.async { [self, completionHandler, originalResponse, result, parameters] in
                completionHandler(originalResponse.response ?? HTTPURLResponse(), result)
                switch result {
                case .success:
                    if options.contains(.successSound) {
                        Self.haptic.prepare()
                        Self.haptic.notificationOccurred(.success)
                    }
                case .failure(let response):
                    if options.contains(.failedSound) {
                        Self.haptic.prepare()
                        Self.haptic.notificationOccurred(.success)
                    }
                    if let response = response as? Error, options.contains(.executeErrorHandlerOnError) {
                        self.commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, response)
                    }
                case .error(let error):
                    if options.contains(.failedSound) {
                        Self.haptic.prepare()
                        Self.haptic.notificationOccurred(.error)
                    }
                    if options.contains(.executeErrorHandlerOnError) {
                        self.commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
            }
        })
    }
}
// swiftlint:enable line_length
