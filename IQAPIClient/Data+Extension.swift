//
//  Data+Extension.swift
//  IQAPIClient
//
//  Created by Iftekhar on 14/10/20.
//

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
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return data.string
        } catch {
            print(error)
        }

        return nil
    }

    var json: [String:Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: []) as? [String:Any]
            return json
        } catch {
            print(error)
        }

        return nil
    }
}
