//
//  Array+Extension.swift
//  IQAPIClient
//
//  Created by Iftekhar on 14/10/20.
//

import Foundation

internal extension Array where Element == [String:Any] {

    var jsonString: String? {
        guard let data = data else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    var data: Data? {

        guard JSONSerialization.isValidJSONObject(self) else {
            print("Invalid JSON")
            return nil
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return data
        } catch {
            print(error)
        }

        return nil
    }
}
