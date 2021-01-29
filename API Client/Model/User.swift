//
//  User.swift
//
//  Created by Iftekhar on 14/04/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import UIKit

/**
 {
   "email" : "charles.morris@reqres.in",
   "id" : 5,
   "last_name" : "Morris",
   "first_name" : "Charles",
   "avatar" : "https:\/\/reqres.in\/img\/faces\/5-image.jpg"
 }
 */
struct User: Decodable {

    let id: Int
    var name: String
    var email: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "first_name"
        case email = "email"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }

    init(attributes: [String: Any]) {
        id = attributes["id"] as? Int ?? -1
        name = attributes["first_name"] as? String ?? ""
        email = attributes["email"] as? String ?? ""
    }
}

struct UncodedUser {

    let id: Int
    var name: String
    var email: String?
    var phone: String?
    var photo: URL?
}
