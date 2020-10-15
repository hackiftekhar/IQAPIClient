//
//  IQAPIClient+Configuration.swift
//  API Client
//
//  Created by Iftekhar on 09/09/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import Foundation
import IQAPIClient

internal enum ITAPIPath: String {

    case push_register      =   "/push/register.php"

    case register           =   "/user/register.php"
    case roles              =   "/user/roles.php"
    case session            =   "/user/session.php"
    case profile            =   "/user/profile.php"

    case change_password    =   "/user/password/change.php"
    case forgot_password    =   "/user/password/forgot.php"
}

public struct APIMessage : Codable {
    let status : Int
    let message : String
}

public struct APIData<T: Decodable>: Decodable {
    let status : Int
    let data : T
}

