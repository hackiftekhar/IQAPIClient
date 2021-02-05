//
//  IQAPIClientConstants.swift
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

public enum NSURLSuccess: Int {
    case success200                 = 200
    case created201                 = 201
    case accepted202                = 202
}

public enum NSURLClientError: Int {
    case badRequest400                      = 400
    case unauthorized401                    = 401
    case paymentRequired402                 = 402
    case forbidden403                       = 403
    case notFound404                        = 404
    case methodNotAllowed405                = 405
    case notAcceptable406                   = 406
    case proxyAuthenticationRequired407     = 407
    case requestTimeout408                  = 408
    case conflict409                        = 409
    case gone410                            = 410
    case lengthRequired411                  = 411
    case preconditionFailed412              = 412
    case payloadTooLarge413                 = 413
    case requestURITooLong414               = 414
    case unsupportedMediaType415            = 415
    case requestedRangeNotSatisfiable416    = 416
    case expectationFailed417               = 417
    case unprocessableEntity422             = 422
    case emailNotPermitted423               = 423
    case emailAlreadyUsed424                = 424
    case activityAlreadyExist425            = 425
}

public enum NSURLServerError: Int {
    case internalServerError500             = 500
    case notImplemented501                  = 501
    case badGateway502                      = 502
    case serviceUnavailable503              = 503
    case gatewayTimeout504                  = 504
    case httpVersionNotSupported505         = 505
}
