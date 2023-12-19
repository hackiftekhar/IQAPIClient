//
//  IQAPIClient+Concurrency.swift
//  IQAPIClient
//
//  Created by Iftekhar on 12/19/23.
//

import Foundation
@preconcurrency import Alamofire

extension IQAPIClient {

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success>(path: String,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoding: ParameterEncoding? = nil,
                                                        headers: HTTPHeaders? = nil,
                                                        options: Options = []) async throws -> Success
    where Success: Sendable {
        let result: (httpResponse: HTTPURLResponse, result: Success)
        result = try await sendRequest(path: path, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)
        return result.result
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public func sendRequest<Success>(path: String,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoding: ParameterEncoding? = nil,
                                                        headers: HTTPHeaders? = nil,
                                                        options: Options = []) async throws -> (httpResponse: HTTPURLResponse, result: Success)
    where Success: Sendable {

        guard let baseURL = baseURL else { fatalError("baseURL is not specified.") }

        let result: (response: DataResponse<Data, AFError>, result: IQAPIClient.Result<Success, Error>)
        result = try await _sendRequest(url: baseURL.appendingPathComponent(path), method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)

        switch result.result {
        case .success(let response):
            if options.contains(.successSound) {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.success)
            }
            return (result.response.response ?? HTTPURLResponse(), response)
        case .failure(let response):
            if options.contains(.failedSound) {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.success)
            }

            if options.contains(.executeErrorHandlerOnError) {
                commonErrorHandlerBlock?(result.response.request!, parameters, result.response.data, response)
            }

            throw response
        case .error(let error):
            if options.contains(.failedSound) {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.error)
            }

            if options.contains(.executeErrorHandlerOnError) {
                commonErrorHandlerBlock?(result.response.request!, parameters, result.response.data, error)
            }

            throw error
        }
    }
}
