//
//  IQAPIClient+Interceptor.swift
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

internal extension IQAPIClient {

    // swiftlint:disable identifier_name
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable line_length
    // swiftlint:disable function_body_length
    static func intercept<Success, Failure>(response: AFDataResponse<Data>, data: Data) -> IQAPIClient.Result<Success, Failure> {

        let modifiedObject: Any?
        let modifiedError: Error?
        var isFailure = false
        if let json = data.json {
            // Asking from responseModifiedBlock to return the modified dictionary which should be processed
            if let responseModifierBlock = responseModifierBlock {
                let modifiedResult = responseModifierBlock(response, json)
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
            modifiedObject = data
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
                            } catch let error {
                                success = nil
                                successDecodeError = error
                            }
                        } else {
                            success = nil
                            let message = "\(Success.self) does not confirm to Decodable protocol."
                            successDecodeError = NSError(domain: NSStringFromClass(Self.self),
                                                         code: NSURLErrorCannotDecodeRawData,
                                                         userInfo: [NSLocalizedDescriptionKey: message])
                        }
                    } else if let modifiedObject = modifiedObject as? Data {
                        if let Success = Success.self as? Decodable.Type {
                            do {
                                success = try Success.decode(from: modifiedObject) as? Success
                            } catch let error {
                                success = nil
                                successDecodeError = error
                            }
                        } else {
                            success = nil
                            let message = "\(Success.self) does not confirm to Decodable protocol."
                            successDecodeError = NSError(domain: NSStringFromClass(Self.self),
                                                         code: NSURLErrorCannotDecodeRawData,
                                                         userInfo: [NSLocalizedDescriptionKey: message])
                        }
                    } else {
                        success = nil
                    }

                    if let success = success {
                        return .success(success)
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
                        } catch let error {
                            failure = nil
                            failureDecodeError = error
                        }
                    } else {
                        failure = nil
                        let message = "\(Failure.self) does not confirm to Decodable protocol."
                        failureDecodeError = NSError(domain: NSStringFromClass(Self.self),
                                                     code: NSURLErrorCannotDecodeRawData,
                                                     userInfo: [NSLocalizedDescriptionKey: message])
                    }
                } else {
                    failure = nil
                }

                if let failure = failure {
                    return .failure(failure)
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

                    let error = NSError(domain: NSStringFromClass(Self.self),
                                        code: NSURLErrorCannotDecodeRawData,
                                        userInfo: [NSLocalizedDescriptionKey: decodeErrorMessage])
                    return .error(error)
                }
            } catch let error {
                return .error(error)
            }
        } else if let modifiedError = modifiedError {
            return .error(modifiedError)
        } else {
            let error = NSError(domain: NSStringFromClass(Self.self),
                                code: NSURLErrorCannotDecodeRawData,
                                userInfo: [NSLocalizedDescriptionKey: decodeErrorMessage])
            return .error(error)
        }
    }
}
