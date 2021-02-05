//
//  ColorViewController.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//


import UIKit
import IQAPIClient
import Alamofire
import IQListKit

class ColorViewController: UITableViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    lazy var list = IQList(listView: tableView, delegateDataSource: self)

    var color: Color!

    override func viewDidLoad() {
        super.viewDidLoad()

        list.performUpdates({
            let section = IQSection(identifier: 0)
            list.append(section)
        }, animatingDifferences: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
        getUser()
    }

    private func getUser() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()

        IQAPIClient.color(id: color.id) { [weak self] (result) in

            self?.activityIndicator.stopAnimating()

            switch result {
            case .success(let color):
                self?.color = color
                self?.refreshUI()
            case .failure(let error):
                break
            }
        }
    }

    func refreshUI() {
        list.performUpdates {
            let section = IQSection(identifier: 0)
            list.append(section)

            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Color ID", detail: "\(color.id)")], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Name", detail: color.name)], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Year", detail: "\(color.year)")], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Color", detail: color.color)], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Pantone Value", detail: color.pantone_value)], section: section)
        }
    }
}

extension ColorViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath) {

        if let cell = cell as? IQTableViewCell {
            let color = UIColor(hex: self.color.color)
            cell.backgroundColor = color

            if color.isLight {
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
        }
    }
}
