//
//  ITAPIClient.swift
//  Institute
//
//  Created by IE05 on 12/03/20.
//  Copyright © 2020 IE03. All rights reserved.
//

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

    //Base URL of the API
    public static var baseURL: URL!

    //Some customzed error messages on errors
    public static var malformedResponseErrorMessage = "\nLooks like we received malformed response from our server.\n\nHelp us fix the problem by sending error report."
    public static var unintentedResponseErrorMessage = "\nLooks like we received unexpected response from our server.\n\nHelp us fix the problem by sending error report."
    public static var decodeErrorMessage = "Unable to decode server response."

    //A error handler block for all errors (It save a lot of code we write at every place to show error), now implement it and show error message from here, no need to write error alert code everywhere
    public static var commonErrorHandlerBlock: ((URLRequest, Parameters?, Data?, NSError)->Void)?

    //responseModifierBlock is used to modify the response before any processing.
    /*
     Let's say we have below structure of all success response:-
     {
        "status": 200,
        "data": {
            "id":4,
            "name":"Some name"
        }
     }
     In above case, you are only interested in the inner object which is inside data. So from responseModifierBlock you should return `.success(response["data"])` where data is a [String:Any]


     //Let's also assume we another structure of success message
    {
        "status": 200,
        "message": "We have successfully sent you an email with instructions to reset your password."
     }
     In above case, if you are interested in status code also then you could return the same object you received like `.success(response)`.
     Or if you are only interested in "message" and specify returned result type as String like this `Swift.Result<String, NSError>)`, then you should return `.success(response["message"])` where message is a String


     //Let's also assume we another below structure for failure case
     {
        "status": 400,
        "message": "Something went wrong"
     }

     In above case, you should return a `.failure(error)` where you construct an error object like below
     let error = NSError(domain: "Error", code: response["status"] as! Int, userInfo: [NSLocalizedDescriptionKey:response["message"] as! String])
     completionHandler(.failure(error))
     */
    public static var responseModifierBlock: ((URLRequest, [String:Any])->Swift.Result<Any, NSError>)?

    public static var debuggingEnabled = false

    public static var httpHeaders = HTTPHeaders()

    private static let haptic = UINotificationFeedbackGenerator()

    @discardableResult public static func sendRequest<T>(path: String, method: HTTPMethod = .get, parameters: Parameters? = nil,
                                                         successSound: Bool = false, failedSound: Bool = false, executeErroHandlerOnError: Bool = true,
                                                         completionHandler: @escaping (_ result: Swift.Result<T, NSError>) -> Void) -> DataRequest {
        return sendRequest(url: baseURL.appendingPathComponent(path), method: method, parameters: parameters) { (originalResponse: AFDataResponse, result: Swift.Result<Any, NSError>) in
            switch result {

            case .success(let response):
                //Now we are trying to convert the final json to the given object
                do {
                    let object: Any?
                    if let T = T.self as? Decodable.Type {
                        let data = try JSONSerialization.data(withJSONObject: response, options: [])
                        object = T.decode(from: data)
                    } else if let response = response as? T {
                        object = response
                    } else {
                        object = nil
                    }

                    OperationQueue.main.addOperation {
                        if let object = object as? T {
                            if successSound {
                                haptic.prepare()
                                haptic.notificationOccurred(.success)
                            }
                            completionHandler(.success(object))
                        } else {
                            if failedSound {
                                haptic.prepare()
                                haptic.notificationOccurred(.error)
                            }

                            let error = NSError(domain: "IQAPIClientError", code: NSURLErrorCannotDecodeRawData, userInfo: [NSLocalizedDescriptionKey:decodeErrorMessage])
                            completionHandler(.failure(error))
                            if executeErroHandlerOnError {
                                commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                            }
                        }
                    }
                } catch let error as NSError {
                    OperationQueue.main.addOperation {
                        if failedSound {
                            haptic.prepare()
                            haptic.notificationOccurred(.error)
                        }

                        completionHandler(.failure(error))
                        if executeErroHandlerOnError {
                            commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                        }
                    }
                }
            case .failure(let error):
                OperationQueue.main.addOperation {
                    if failedSound {
                        haptic.prepare()
                        haptic.notificationOccurred(.error)
                    }

                    completionHandler(.failure(error))
                    if executeErroHandlerOnError {
                        commonErrorHandlerBlock?(originalResponse.request!, parameters, originalResponse.data, error)
                    }
                }
            }
        }
    }

    private struct RequestCounter {
        static var counter : Int = 0
    }

    @discardableResult internal static func sendRequest<T>(url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil,
                                                           completionHandler: @escaping (_ originalResponse:AFDataResponse<Data>, _ result: Swift.Result<T, NSError>) -> Void) -> DataRequest {

        RequestCounter.counter += 1

        let requestNumber = RequestCounter.counter
        printRequestURL(url: url, method: method, headers: httpHeaders, parameters: parameters, requestNumber: requestNumber)

        let finalCompletionHandler: (AFDataResponse<Data>) -> Void = { (response) in

            printResponse(url: url, response: response, requestNumber: requestNumber)

            switch response.result {
            case .success(let data):    //Successfully got data response from server

                let modifiedObject: T?
                let modifiedError: NSError?
                if let json = data.json {
                    if let responseModifierBlock = responseModifierBlock {  //Asking from responseModifiedBlock to return the modified dictionary which should be processed
                        let modifiedResult = responseModifierBlock(response.request!, json)
                        switch modifiedResult {
                        case .success(let modified):
                            modifiedObject = modified as? T
                            modifiedError = nil
                        case .failure(let error):
                            modifiedObject = nil
                            modifiedError = error
                        }
                    } else {
                        modifiedObject = json as? T
                        modifiedError = nil
                    }
                } else {
                    modifiedObject = nil
                    modifiedError = nil
                }

                if let modifiedObject = modifiedObject {
                    completionHandler(response, .success(modifiedObject))
                } else if let modifiedError = modifiedError {
                    completionHandler(response, .failure(modifiedError))
                } else {
                    let error = NSError(domain: "IQAPIClientError", code: NSURLErrorCannotDecodeRawData, userInfo: [NSLocalizedDescriptionKey:decodeErrorMessage])
                    completionHandler(response, .failure(error))
                }

            case .failure(let error):   //Error from the Alamofire
                completionHandler(response, .failure(error as NSError))
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
