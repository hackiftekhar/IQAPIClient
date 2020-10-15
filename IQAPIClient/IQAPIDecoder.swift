//
//  ITAPICoder.swift
//  Institute
//
//  Created by Iftekhar on 28/08/20.
//  Copyright © 2020 IE03. All rights reserved.
//

import Foundation

internal extension JSONDecoder {

    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.dataDecodingStrategy = .deferredToData
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return decoder
    }()
}

internal extension Decodable {
    
    static func decode(from data: Data) -> Self? {
        do {
            let object = try JSONDecoder.default.decode(self, from: data)
            return object
        } catch {
            print(error)
        }

        return nil
    }
}
