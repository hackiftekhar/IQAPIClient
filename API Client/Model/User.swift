//
//  User.swift
//
//  Created by Iftekhar on 14/04/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import UIKit

struct User: Codable {

    let id: Int
    var name: String
    var email: String?
    var phone: String?
    var photo: URL?
}
