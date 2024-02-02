//
//  ViewController.swift
//  API Client
//
//  Created by Iftekhar on 09/09/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import UIKit
import IQAPIClient
import Alamofire
import IQListKit
import AlamofireImage

class UsersViewController: UITableViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var refreshButton: UIBarButtonItem!

    var users = [User]()

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

//        if #available(iOS 13.0, *) {
//            Task(priority: .background, operation: {
//                do {
//                    let users = try await IQAPIClient.default.asyncAwaitUsers()
//                    self.users = users
//                    self.refreshUI()
//                    self.activityIndicator.stopAnimating()
//                    self.refreshButton.isEnabled = true
//                } catch {
//                    print(error)
//                    self.activityIndicator.stopAnimating()
//                    self.refreshButton.isEnabled = true
//                }
//            })
//        } else {
            IQAPIClient.default.users { result in

                self.activityIndicator.stopAnimating()
                self.refreshButton.isEnabled = true

                switch result {
                case .success(let users):
                    self.users = users
                    self.refreshUI()
                case .failure(let error):
                    print(error)
                }
            }
//        }
    }

    @IBAction func clear(_ sender: UIBarButtonItem) {
        users = []
        refreshUI()
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        getUsersList()
    }

    func refreshUI() {
        list.performUpdates {
            let section = IQSection(identifier: 0)
            list.append(section)

            list.append(UserCell.self, models: users, section: section)
        }
    }
}

extension UsersViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? User {
            if let userController = storyboard?.instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
                userController.user = model
                navigationController?.pushViewController(userController, animated: true)
            }
        }
    }
}
