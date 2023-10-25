//
//  UserCell.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import UIKit
import IQListKit

class UserCell: UITableViewCell, IQModelableCell {
    typealias Model = User

    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }

            textLabel?.text = model.name
            detailTextLabel?.text = model.email
            if let avatar = model.avatar {
                imageView?.af.setImage(withURL: avatar)
            } else {
                imageView?.image = nil
            }
        }
    }
}
