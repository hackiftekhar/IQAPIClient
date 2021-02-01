//
//  ITAPIClient.swift
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

//MARK: - ITAPIClient -

public struct UploadableFile : Hashable {
    public let data : Data
    public let mimeType : String
    public let fileName : String
    public let fileURL: URL?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
        hasher.combine(mimeType)
        hasher.combine(fileName)
    }
    
    public var hashValue: Int {
        return data.hashValue
    }

    public init(data:Data, mimeType:String, fileName:String, fileURL:URL? = nil) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
        self.fileURL = fileURL
    }

    public static func ==(lhs: UploadableFile, rhs: UploadableFile) -> Bool {
        return lhs.data == rhs.data
    }
}

public class IQAPIClient {

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

    /// Some customzed error messages on errors
    public static var malformedResponseErrorMessage = "Looks like we received malformed response from our server."
    public static var unintentedResponseErrorMessage = "Looks like we received unexpected response from our server."
    public static var decodeErrorMessage = "Unable to decode server response."

    /// A error handler block for all errors (It save a lot of code we write at every place to show error), now implement it and show error message from here, no need to write error alert code everywhere
    public static var commonErrorHandlerBlock: ((URLRequest, Parameters?, Data?, Error)->Void)?

///--------------------------
///     responseModifierBlock is used to modify the response before any processing.
///     Let's say we have below structure of all success response:-
//     {
//        "status": 200,
//        "data": {
//            "id":4,
//            "name":"Some name"
//        }
//     }
///     In above case, you are only interested in the inner object which is inside data. So from responseModifierBlock you should return `.success(response["data"])` where data is a [String:Any]
///--------------------------
///    Let's also assume we another structure of success message
//    {
//        "status": 200,
//        "message": "We have successfully sent you an email with instructions to reset your password."
//     }
///     In above case, if you are interested in status code also then you could return the same object you received like `.success(response)`.
///     Or if you are only interested in "message" and specify returned result type as String like this `Result<String, FailureModel, Error>)`, then you should return `.success(response["message"])` where message is a String
///--------------------------
///     Let's also assume we another below structure for failure case
//     {
//        "status": 400,
//        "message": "Something went wrong"
//     }
///
///     In above case, you should return a `.failure(error)` where you construct an error object like below
///     let error = Error(domain: "Error", code: response["status"] as! Int, userInfo: [NSLocalizedDescriptionKey:response["message"] as! String])
///     completionHandler(.failure(error))

    public static var responseModifierBlock: ((URLRequest, Any)->Result<Any, Any>)?

    public static var debuggingEnabled = false

    public static var httpHeaders = HTTPHeaders()

    private static let haptic = UINotificationFeedbackGenerator()

    public static let `jsonDecoder`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.dataDecodingStrategy = .deferredToData
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return decoder
    }()

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public static func sendRequest<Success, Failure>(path: String, method: HTTPMethod = .get, parameters: Parameters? = nil,
                                                                        successSound: Bool = false, failedSound: Bool = false, executeErroHandlerOnError: Bool = true,
                                                                        completionHandler: @escaping (_ result: Result<Success, Failure>) -> Void) -> DataRequest {

        return _sendRequest(url: baseURL.appendingPathComponent(path), method: method, parameters: parameters) { (originalResponse: AFDataResponse, result: Result<Success, Failure>) in
            switch result {
            case .success(let response):
                if successSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.success(response))
                }
                break
            case .failure(let response):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.failure(response))
                }
                break
            case .error(let error):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.error)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.error(error))
                    if executeErroHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
                break
            }
        }
    }

    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    @discardableResult public static func sendRequest<Success>(path: String, method: HTTPMethod = .get, parameters: Parameters? = nil,
                                                               successSound: Bool = false, failedSound: Bool = false, executeErroHandlerOnError: Bool = true,
                                                               completionHandler: @escaping (_ result: Swift.Result<Success, Error>) -> Void) -> DataRequest {

        return _sendRequest(url: baseURL.appendingPathComponent(path), method: method, parameters: parameters) { (originalResponse: AFDataResponse, result: Result<Success, Error>) in
            switch result {
            case .success(let response):
                if successSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.success(response))
                }
                break
            case .failure(let response):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.success)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.failure(response))

                    if executeErroHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, response)
                    }
                }
                break
            case .error(let error):
                if failedSound {
                    haptic.prepare()
                    haptic.notificationOccurred(.error)
                }
                OperationQueue.main.addOperation {
                    completionHandler(.failure(error))

                    if executeErroHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
                break
            }
        }
    }
}

/// internal
internal extension IQAPIClient {

    private struct RequestCounter {
        static var counter : Int = 0
    }

    @discardableResult private static func _sendRequest<Success, Failure>(url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil,
                                                                          completionHandler: @escaping (_ originalResponse:AFDataResponse<Data>, _ result: Result<Success, Failure>) -> Void) -> DataRequest {

        guard Success.Type.self != Failure.Type.self else {
            fatalError("Success \(Success.self) and Failure \(Failure.self) must not be of same type")
        }

        RequestCounter.counter += 1

        let requestNumber = RequestCounter.counter
        printRequestURL(url: url, method: method, headers: httpHeaders, parameters: parameters, requestNumber: requestNumber)

        let finalCompletionHandler: (AFDataResponse<Data>) -> Void = { (response) in

            printResponse(url: url, response: response, requestNumber: requestNumber)

            switch response.result {
            case .success(let data):    /// Successfully got data response from server
                let modifiedObject: Any?
                let modifiedError: Error?
                var isFailure = false
                if let json = data.json {
                    if let responseModifierBlock = responseModifierBlock {  /// Asking from responseModifiedBlock to return the modified dictionary which should be processed
                        let modifiedResult = responseModifierBlock(response.request!, json)
                        switch modifiedResult {
                        case .success(let modified):
                            modifiedObject = modified
                            modifiedError = nil
                        case .failure(let modified):
                            modifiedObject = modified
                            modifiedError = nil
                            isFailure = true
                        case .error(let error):
                            modifiedObject = nil
                            modifiedError = error
                        }
                    } else {
                        modifiedObject = json
                        modifiedError = nil
                    }
                } else {
                    modifiedObject = nil
                    modifiedError = nil
                }

                if let modifiedObject = modifiedObject {
                    do {
                        var successDecodeError: Error?
                        var failureDecodeError: Error?
                        if isFailure == false {
                            let success: Success?
                            if let response = modifiedObject as? Success {
                                success = response
                            } else if JSONSerialization.isValidJSONObject(modifiedObject) {
                                if let Success = Success.self as? Decodable.Type {
                                    let data = try JSONSerialization.data(withJSONObject: modifiedObject, options: [])
                                    do {
                                        success = try Success.decode(from: data) as? Success
                                    } catch {
                                        success = nil
                                        successDecodeError = error
                                    }
                                } else {
                                    success = nil
                                    let message = "\(Success.self) does not confirm to Decodable protocol."
                                    successDecodeError = NSError(domain: NSStringFromClass(Self.self), code: NSURLErrorCannotDecodeRawData, userInfo: [NSLocalizedDescriptionKey: message])
                                }
                            } else {
                                success = nil
                            }

                            if let success = success {
                                completionHandler(response, .success(success))
                                return
                            }
                        }

                        let failure: Failure?
                        if let response = modifiedObject as? Failure {
                            failure = response
                        } else if JSONSerialization.isValidJSONObject(modifiedObject) {
                            if let Failure = Failure.self as? Decodable.Type {
                                let data = try JSONSerialization.data(withJSONObject: modifiedObject, options: [])
                                do {
                                    failure = try Failure.decode(from: data) as? Failure
                                } catch {
                                    failure = nil
                                    failureDecodeError = error
                                }
                            } else {
                                failure = nil
                                let message = "\(Failure.self) does not confirm to Decodable protocol."
                                failureDecodeError = NSError(domain: NSStringFromClass(Self.self), code: NSURLErrorCannotDecodeRawData, userInfo: [NSLocalizedDescriptionKey: message])
                            }
                        } else {
                            failure = nil
                        }

                        if let failure = failure {
                            completionHandler(response, .failure(failure))
                        } else {

                            if debuggingEnabled, (successDecodeError != nil || failureDecodeError != nil) {

                                var finalMessges = [String]()

                                finalMessges.append("\nReceived \'\(type(of: modifiedObject.self))\' type response.")

                                if let successDecodeError = successDecodeError {

                                    finalMessges.append("Unable to decode server response to \'\(Success.self)\' type.")
                                    print("\n\(Success.self): \(successDecodeError)")
                                }

                                if let failureDecodeError = failureDecodeError {
                                    finalMessges.append("Unable to decode server response to \'\(Failure.self)\' type.")
                                    print("\n\(Failure.self): \(failureDecodeError)")
                                }

                                print(finalMessges.joined(separator: "\n\n"))
                            }

                            let error = NSError(domain: NSStringFromClass(Self.self), code: NSURLErrorCannotDecodeRawData, userInfo: [NSLocalizedDescriptionKey:decodeErrorMessage])
                            completionHandler(response, .error(error))
                        }
                    } catch {
                        completionHandler(response, .error(error))
                    }
                } else if let modifiedError = modifiedError {
                    completionHandler(response, .error(modifiedError))
                } else {
                    let error = NSError(domain: NSStringFromClass(Self.self), code: NSURLErrorCannotDecodeRawData, userInfo: [NSLocalizedDescriptionKey:decodeErrorMessage])
                    completionHandler(response, .error(error))
                }

            case .failure(let error):   /// Error from the Alamofire
                completionHandler(response, .error(error))
            }
        }

        let isMultipart = parameters?.firstIndex(where: { (_, value) -> Bool in value is UploadableFile }) != nil

        let request: DataRequest

        if isMultipart {
            request = AF.upload(multipartFormData: { (multipartFormData) in
                if let parameters = parameters {
                    for (key, value) in parameters {
                        if let data = value as? UploadableFile {
                            multipartFormData.append(data.data, withName: key, fileName: data.fileName, mimeType: data.mimeType)
                        } else {
                            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                        }
                    }
                }
            }, to: url, method: method, headers: httpHeaders)
        } else {
            request = AF.request(url, method: method, parameters: parameters, encoding: (method == .get ? URLEncoding.default : JSONEncoding.default), headers: httpHeaders)
        }

        request.responseData(queue: DispatchQueue.global(qos: .default), completionHandler: finalCompletionHandler)
        return request
    }
}
