//
//  Color.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import Foundation

/**
 {
   "id": 2,
   "name": "fuchsia rose",
   "year": 2001,
   "color": "#C74375",
   "pantone_value": "17-2031"
 },
 */

struct Color: Decodable, Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: Int
    var name: String
    var year: Int
    var color: String
    var pantone_value: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case year = "year"
        case color = "color"
        case pantone_value = "pantone_value"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        year = try container.decode(Int.self, forKey: .year)
        color = try container.decode(String.self, forKey: .color)
        pantone_value = try container.decode(String.self, forKey: .pantone_value)
    }
}
