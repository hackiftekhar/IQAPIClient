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

import UIKit
import Alamofire

// If you would like to convert your JSON responses to model online,
// then https://jsonmaster.github.io/ site will help you to do it quickly.

final public class IQAPIClient {

    @frozen public enum Result<Success, Failure> {

        /// A success, storing a `Success` value.
        case success(Success)

        /// A success, storing a `Success` value.
        case failure(Failure)

        /// A error, storing a `Error` value.
        case error(Error)

    }

    /// Base URL of the API
    public static var baseURL: URL!

    /// Alamofire Setup
    public static var session = Session(rootQueue: DispatchQueue(label: "com.iqapiclient.rootQueue"))
    private static let responseQueue: DispatchQueue = DispatchQueue(label: "com.iqapiclient.responseQueue",
                                                                    attributes: .concurrent)

    /// Some customzed error messages on errors
    public static var malformedResponseErrorMessage = "Looks like we received malformed response from our server."
    public static var unintentedResponseErrorMessage = "Looks like we received unexpected response from our server."
    public static var decodeErrorMessage = "Unable to decode server response."

    /// A error handler block for all errors (It save a lot of code we write at every place to show error),
    /// now implement it and show error message from here, no need to write error alert code everywhere
    public static var commonErrorHandlerBlock: ((URLRequest, Parameters?, Data?, Error) -> Void)?

/// --------------------------
///     responseModifierBlock is used to modify the response before any processing.
///     Let's say we have below structure of all success response:-
//     {
//        "status": 200,
//        "data": {
//            "id":4,
//            "name":"Some name"
//        }
//     }
//     In above case, you are only interested in the inner object which is inside data.
//      So from responseModifierBlock you should return `.success(response["data"])` where data is a [String:Any]
/// --------------------------
///    Let's also assume we another structure of success message
//    {
//        "status": 200,
//        "message": "We have successfully sent you an email with instructions to reset your password."
//     }
//     In above case, if you are interested in status code also
//     then you could return the same object you received like `.success(response)`.
//     Or if you are only interested in "message" and specify returned result type as String like this
//    `Result<String, FailureModel, Error>)`, then you should return `.success(response["message"])`
/// --------------------------
///     Let's also assume we another below structure for failure case
//     {
//        "status": 400,
//        "message": "Something went wrong"
//     }
///
///     In above case, you should return a `.failure(error)` where you construct an error object like below
//     let error = Error(domain: "Error",
//                      code: response["status"] as! Int,
//                      userInfo: [NSLocalizedDescriptionKey:response["message"] as! String])
//     completionHandler(.failure(error))

    public static var responseModifierBlock: ((AFDataResponse<Data>, Any)->IQAPIClient.Result<Any, Any>)?

    public static var debuggingEnabled = false

    public static var httpHeaders = HTTPHeaders()

    internal static let haptic = UINotificationFeedbackGenerator()

    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.dataDecodingStrategy = .deferredToData
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity",
                                                                        negativeInfinity: "-Infinity",
                                                                        nan: "NaN")
        return decoder
    }()

    // swiftlint:disable line_length
    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public static func sendRequest<Success, Failure>(path: String,
                                                                        method: HTTPMethod = .get,
                                                                        parameters: Parameters? = nil,
                                                                        encoding: ParameterEncoding? = nil,
                                                                        headers: HTTPHeaders? = nil,
                                                                        successSound: Bool = false,
                                                                        failedSound: Bool = false,
                                                                        executeErrorHandlerOnError: Bool = true,
                                                                        forceMultipart: Bool = false,
                                                                        completionHandler: @escaping (_ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {

        assert(baseURL != nil, "basseURL is not specified.")

        return _sendRequest(url: baseURL.appendingPathComponent(path),
                            method: method,
                            parameters: parameters,
                            encoding: encoding,
                            headers: headers,
                            forceMultipart: forceMultipart,
                            completionHandler: { (originalResponse: AFDataResponse, result: IQAPIClient.Result<Success, Failure>) in
            switch result {
            case .success(let response):
                if successSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.success(response))
                }
            case .failure(let response):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.failure(response))
                }
            case .error(let error):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.error)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.error(error))
                    if executeErrorHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
            }
        })
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public static func sendRequest<Success>(path: String,
                                                               method: HTTPMethod = .get,
                                                               parameters: Parameters? = nil,
                                                               encoding: ParameterEncoding? = nil,
                                                               headers: HTTPHeaders? = nil,
                                                               successSound: Bool = false,
                                                               failedSound: Bool = false,
                                                               executeErrorHandlerOnError: Bool = true,
                                                               forceMultipart: Bool = false,
                                                               completionHandler: @escaping (_ result: Swift.Result<Success, Error>) -> Void) -> DataRequest {

        assert(baseURL != nil, "basseURL is not specified.")

        return _sendRequest(url: baseURL.appendingPathComponent(path),
                            method: method,
                            parameters: parameters,
                            encoding: encoding,
                            headers: headers,
                            forceMultipart: forceMultipart,
                            completionHandler: { (originalResponse: AFDataResponse, result: IQAPIClient.Result<Success, Error>) in
            switch result {
            case .success(let response):
                if successSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.success(response))
                }
            case .failure(let response):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.failure(response))

                    if executeErrorHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, response)
                    }
                }
            case .error(let error):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.error)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.failure(error))

                    if executeErrorHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
            }
        })
    }
}

/// internal
internal extension IQAPIClient {

    private struct RequestCounter {
        static var counter: Int = 0
    }

    // swiftlint:disable line_length
    @discardableResult private static func _sendRequest<Success, Failure>(url: URLConvertible,
                                                                          method: HTTPMethod = .get,
                                                                          parameters: Parameters? = nil,
                                                                          encoding: ParameterEncoding? = nil,
                                                                          headers: HTTPHeaders? = nil,
                                                                          forceMultipart: Bool = false,
                                                                          completionHandler: @escaping (_ originalResponse: AFDataResponse<Data>, _ result: IQAPIClient.Result<Success, Failure>) -> Void) -> DataRequest {

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
        printRequestURL(url: url, method: method, headers: httpHeaders,
                        parameters: parameters, requestNumber: requestNumber)

        let finalCompletionHandler: (AFDataResponse<Data>) -> Void = { (response) in

            printResponse(url: url, response: response, requestNumber: requestNumber)

            switch response.result {
            case .success(let data):    /// Successfully got data response from server
                let result: IQAPIClient.Result<Success, Failure> = intercept(response: response, data: data)
                completionHandler(response, result)
            case .failure(let error):   /// Error from the Alamofire
                completionHandler(response, .error(error))
            }
        }

        let isMultipart = containsAnyFile(parameters: parameters)

        let request: DataRequest

        if isMultipart || forceMultipart {
            request = session.upload(multipartFormData: { (multipartFormData) in
                if let parameters = parameters {
                    addToMultipartFormData(multipartFormData, fromKey: "", parameters: parameters)
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
        request.responseData(queue: responseQueue, completionHandler: finalCompletionHandler)
        return request
    }

    private static func containsAnyFile(parameters: Any?) -> Bool {

        switch parameters {
        case let array as [Any]:

            for object in array {
                if self.containsAnyFile(parameters: object) {
                    return true
                }
            }

            return false

        case let dictionary as [String: Any]:

            for object in dictionary.values {
                if self.containsAnyFile(parameters: object) {
                    return true
                }
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
}
