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
// then you could try these sites
// https://jsonmaster.github.io
// https://app.quicktype.io         Change snake_case to camelCase
// https://www.json4swift.com       Preserves snake_cases
// https://json2kt.com/             It change the snake_case to camelCase but format the code  beautifully
// https://github.com/insanoid/SwiftyJSONAccelerator    This is an app which can be installed on your mac

final public class IQAPIClient: Sendable {

    @frozen public enum Result<Success, Failure>: Sendable where Success: Sendable, Failure: Sendable {

        /// A success, storing a `Success` value.
        case success(Success)

        /// A success, storing a `Success` value.
        case failure(Failure)

        /// A error, storing a `Error` value.
        case error(Error)

    }

    public static let `default` = IQAPIClient()

    public init(baseURL: URL? = nil, identifier: String? = nil) {
        self.baseURL = baseURL

        var rootQueueName: String = "com.iqapiclient.rootQueue"
        var serializationQueueName: String = "com.iqapiclient.serializationQueue"
        var responseQueueName: String = "com.iqapiclient.responseQueue"
        if let baseURL = baseURL {
            rootQueueName += "_\(baseURL.absoluteString)"
            serializationQueueName += "_\(baseURL.absoluteString)"
            responseQueueName += "_\(baseURL.absoluteString)"
        }

        session = Session(rootQueue: DispatchQueue(label: rootQueueName),
                          serializationQueue: DispatchQueue(label: serializationQueueName,
                                                            attributes: .concurrent))
        responseQueue = DispatchQueue(label: responseQueueName,
                                      attributes: .concurrent)
    }

    /// Base URL of the API
    public var baseURL: URL?

    /// Alamofire Setup
    public var session: Session
    internal let responseQueue: DispatchQueue

    /// Some customized error messages on errors
    public var malformedResponseErrorMessage = "Looks like we received malformed response from our server."
    public var unexpectedResponseErrorMessage = "Looks like we received unexpected response from our server."
    public var decodeErrorMessage = "Unable to decode server response."

    /// A error handler block for all errors (It save a lot of code we write at every place to show error),
    /// now implement it and show error message from here, no need to write error alert code everywhere
    public var commonErrorHandlerBlock: ((_ request: URLRequest, _ parameters: Any?, _ data: Data?, _ error: Error) -> Void)?

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

    public var responseModifierBlock: ((AFDataResponse<Data>, Any) -> IQAPIClient.Result<Any, Any>)?

    public var debuggingEnabled = false

    public var httpHeaders = HTTPHeaders()

    @MainActor
    internal static let haptic = UINotificationFeedbackGenerator()

    public var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.dataDecodingStrategy = .deferredToData
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity",
                                                                        negativeInfinity: "-Infinity",
                                                                        nan: "NaN")
        return decoder
    }()

    public var jsonEncoder: JSONEncoder = {
        let decoder = JSONEncoder()
        decoder.dateEncodingStrategy = .secondsSince1970
        decoder.dataEncodingStrategy = .deferredToData
        decoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "+Infinity",
                                                                      negativeInfinity: "-Infinity",
                                                                      nan: "NaN")
        return decoder
    }()

    public struct Options: OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let successSound                  = Self.init(rawValue: 1 << 0)
        public static let failedSound                   = Self.init(rawValue: 1 << 1)
        public static let executeErrorHandlerOnError    = Self.init(rawValue: 1 << 2)
        public static let forceMultipart                = Self.init(rawValue: 1 << 3)
    }
}
