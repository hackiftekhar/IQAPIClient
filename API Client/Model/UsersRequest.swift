//
//  UsersRequest.swift
//  API Client
//
//  Created by Iftekhar on 01/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import Foundation

struct UsersRequest: Encodable {
    let pageIndex: Int
    let pageSize: Int
}
