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
}

// swiftlint:disable line_length
// swiftlint:disable identifier_name
// swiftlint:disable function_parameter_count
internal extension IQAPIClient {
    @discardableResult func _sendRequest<Success, Failure>(url: URLConvertible,
                                                           method: HTTPMethod,
                                                           parameters: Parameters?,
                                                           encoding: ParameterEncoding?,
                                                           headers: HTTPHeaders?,
                                                           options: Options,
                                                           completionHandler: @Sendable @escaping @MainActor (_ originalResponse: AFDataResponse<Data>, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest
    where Success: Sendable, Failure: Sendable {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        let (request, requestNumber) = newRequest(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)
        Task.detached(priority: .utility) {
            let response = await request.serializingData().response

            let result: IQAPIClient.Result<Success, Failure> = await self.handleResponse(response: response, parameters: parameters, options: options, requestNumber: requestNumber)
            switch result {
            case .success, .failure:
                return (request, result)
            case .error(let error):
                throw error
            }
        }
        return request
    }

    @discardableResult func _sendRequest<Success, Failure, Parameters>(url: URLConvertible,
                                                                       method: HTTPMethod,
                                                                       parameters: Parameters?,
                                                                       encoder: ParameterEncoder?,
                                                                       headers: HTTPHeaders?,
                                                                       options: Options,
                                                                       completionHandler: @Sendable @escaping @MainActor (_ originalResponse: AFDataResponse<Data>, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest
    where Success: Sendable, Failure: Sendable, Parameters: Encodable {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        let (request, requestNumber) = newRequest(url: url, method: method, parameters: parameters, encoder: encoder, headers: headers, options: options)
        Task.detached(priority: .utility) {
            let response = await request.serializingData().response

            let result: IQAPIClient.Result<Success, Failure> = await self.handleResponse(response: response, parameters: parameters, options: options, requestNumber: requestNumber)
            switch result {
            case .success, .failure:
                return (request, result)
            case .error(let error):
                throw error
            }
        }
        return request
    }
}

internal extension IQAPIClient {

    func _sendRequest<Success, Failure>(url: URLConvertible,
                                        method: HTTPMethod,
                                        parameters: Parameters?,
                                        encoding: ParameterEncoding?,
                                        headers: HTTPHeaders?,
                                        options: Options) async throws -> (response: DataResponse<Data, AFError>, result: IQAPIClient.Result<Success, Failure>)
    where Success: Sendable, Failure: Sendable {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        let (request, requestNumber) = newRequest(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)
        let response = await request.serializingData().response

        let result: IQAPIClient.Result<Success, Failure> = await handleResponse(response: response, parameters: parameters, options: options, requestNumber: requestNumber)

        switch result {
        case .success, .failure:
            return (response, result)
        case .error(let error):
            throw error
        }
    }

    func _sendRequest<Success, Failure, Parameters>(url: URLConvertible,
                                                    method: HTTPMethod,
                                                    parameters: Parameters?,
                                                    encoder: ParameterEncoder?,
                                                    headers: HTTPHeaders?,
                                                    options: Options) async throws -> (response: DataResponse<Data, AFError>, result: IQAPIClient.Result<Success, Failure>)
    where Success: Sendable, Failure: Sendable, Parameters: Encodable {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        let (request, requestNumber) = newRequest(url: url, method: method, parameters: parameters, encoder: encoder, headers: headers, options: options)
        let response = await request.serializingData().response

        let result: IQAPIClient.Result<Success, Failure> = await handleResponse(response: response, parameters: parameters, options: options, requestNumber: requestNumber)
        switch result {
        case .success, .failure:
            return (response, result)
        case .error(let error):
            throw error
        }
    }
}

private extension IQAPIClient {

    func newRequest(url: URLConvertible,
                    method: HTTPMethod,
                    parameters: Parameters?,
                    encoding: ParameterEncoding?,
                    headers: HTTPHeaders?,
                    options: Options) -> (request: DataRequest, number: Int) {

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
        Task.detached(priority: .utility) { [httpHeaders] in
            await self.printRequestURL(url: url, method: method, headers: httpHeaders,
                                       parameters: parameters, requestNumber: requestNumber)
        }

        let isMultipart = Self.containsAnyFile(parameters: parameters)

        let request: DataRequest

        if isMultipart || options.contains(.forceMultipart) {
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
        return (request, requestNumber)
    }

    func newRequest<Parameters: Encodable>(url: URLConvertible,
                                           method: HTTPMethod,
                                           parameters: Parameters?,
                                           encoder: ParameterEncoder?,
                                           headers: HTTPHeaders?,
                                           options: Options) -> (request: DataRequest, number: Int) {

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
        Task.detached(priority: .utility) { [httpHeaders] in
            await self.printRequestURL(url: url, method: method, headers: httpHeaders,
                                       parameters: parameters, requestNumber: requestNumber)
        }

        let isMultipart = Self.containsAnyFile(parameters: parameters)

        let request: DataRequest

        if isMultipart || options.contains(.forceMultipart) {
            request = session.upload(multipartFormData: { (multipartFormData) in
                if let parameters = parameters {
                    Self.addToMultipartFormData(multipartFormData, fromKey: "", parameters: parameters)
                }
            }, to: url, method: method, headers: httpHeaders)
        } else {

            let finalEncoder: ParameterEncoder
            if let encoder = encoder {
                finalEncoder = encoder
            } else {
                finalEncoder = (method == .get ? URLEncodedFormParameterEncoder.default : JSONParameterEncoder.default)
            }

            request = session.request(url, method: method, parameters: parameters, encoder: finalEncoder, headers: httpHeaders)
        }
        return (request, requestNumber)
    }

    func handleResponse<Success, Failure>(response: AFDataResponse<Data>, parameters: Any?, options: Options,
                                          requestNumber: Int) async -> IQAPIClient.Result<Success, Failure>
    where Success: Sendable, Failure: Sendable {
        Task.detached(priority: .utility) {
            await self.printResponse(response: response, requestNumber: requestNumber)
        }

        let result: IQAPIClient.Result<Success, Failure>
        switch response.result {
        case .success(let data):    /// Successfully got data response from server
            result = intercept(response: response, data: data)
        case .failure(let error):   /// Error from the Alamofire
            result = .error(error)
        }

        switch result {
        case .success:
            if options.contains(.successSound) {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.success)
            }
        case .failure(let failure):
            if options.contains(.failedSound) {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.success)
            }

            if options.contains(.executeErrorHandlerOnError), let failure = failure as? Error {
                commonErrorHandlerBlock?(response.request!, parameters, response.data, failure)
            }
        case .error(let error):
            if options.contains(.failedSound) {
                await Self.haptic.prepare()
                await Self.haptic.notificationOccurred(.error)
            }

            if options.contains(.executeErrorHandlerOnError) {
                commonErrorHandlerBlock?(response.request!, parameters, response.data, error)
            }
        }

        return result
    }

    static func containsAnyFile(parameters: Any?) -> Bool {

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
    static func addToMultipartFormData(_ multipartFormData: MultipartFormData, fromKey key: String, parameters: Any) {

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
    // swiftlint:enable cyclomatic_complexity
}
// swiftlint:enable line_length
// swiftlint:enable identifier_name
// swiftlint:enable function_parameter_count
