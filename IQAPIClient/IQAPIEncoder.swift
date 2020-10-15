//
//  ITAPICoder.swift
//  Institute
//
//  Created by Iftekhar on 28/08/20.
//  Copyright © 2020 IE03. All rights reserved.
//

import Foundation

internal extension JSONEncoder {

    static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.dataEncodingStrategy = .deferredToData
        return encoder
    }()
}

internal extension Encodable {

    var dictionary: [String: Any]? {
        guard let data = data, let dictionary = data.dictionary else { return nil }
        return dictionary
    }

    var data: Data? {
        do {
            let data = try JSONEncoder.default.encode(self)
            return data
        } catch {
            print(error)
        }

        return nil
    }
}
