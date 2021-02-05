//
//  ColorsViewController.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import UIKit
import IQAPIClient
import Alamofire
import IQListKit

class ColorsViewController: UITableViewController {

    typealias Cell = ColorCell
    typealias Model = Color

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var refreshButton: UIBarButtonItem!
    var models = [Model]()

    lazy var list = IQList(listView: tableView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        list.performUpdates({
            let section = IQSection(identifier: 0)
            list.append(section)
        }, animatingDifferences: false)
    }

    private func getUsersList() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()
        refreshButton.isEnabled = false

        IQAPIClient.colors { [weak self] result in
            self?.activityIndicator.stopAnimating()
            self?.refreshButton.isEnabled = true

            switch result {
            case .success(let models):
                self?.models = models
                self?.refreshUI()
            case .failure:
                break
            }
        }
    }

    @IBAction func clear(_ sender: UIBarButtonItem) {
        models = []
        refreshUI()
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        getUsersList()
    }

    func refreshUI() {
        list.performUpdates {
            let section = IQSection(identifier: 0)
            list.append(section)

            list.append(Cell.self, models: models, section: section)
        }
    }
}

extension ColorsViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? Model {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "ColorViewController") as? ColorViewController {
                controller.color = model
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
