//
//  Data+Extension.swift
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

internal extension Data {

    var string: String? {
        return String(data: self, encoding: .utf8)
    }

    var jsonString: String? {
        guard let json = json, JSONSerialization.isValidJSONObject(json) else {
            print("Invalid JSON")
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return data.string
        } catch let error {
            print(error)
        }

        return nil
    }

    var prettyJsonString: String? {
        guard let json = json, JSONSerialization.isValidJSONObject(json) else {
            print("Invalid JSON")
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return data.string
        } catch let error {
            print(error)
        }

        return nil
    }

    var json: Any? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])

            // This swift typecasting is useful for debugging purposes
            if let json = json as? [String: Any] {
                return json
            } else if let json = json as? [[String: Any]] {
                return json
            } else if let json = json as? [Any] {
                return json
            } else {
                return json
            }
        } catch let error {
            print(error)
        }

        return nil
    }
}
