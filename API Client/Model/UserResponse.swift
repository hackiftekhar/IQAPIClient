//
//  UserResponse.swift
//  API Client
//
//  Created by Iftekhar on 29/01/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import Foundation

struct UserResponse<T>: Decodable where T: Decodable {
    let total: Int
    let total_pages: Int
    let per_page: Int
    let page: Int
    let data: T
}
