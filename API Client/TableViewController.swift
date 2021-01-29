//
//  ViewController.swift
//  API Client
//
//  Created by Iftekhar on 09/09/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import UIKit
import IQAPIClient

class TableViewController: UITableViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func getUsersList1() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()
        let request = IQAPIClient.getUsersList1 { [weak self] result in
            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let data):
//                self?.users = data.data
                self?.refreshUI()
            case .failure(let response):
                let alertController = UIAlertController(title: "Failed", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                print(response)
            case .error(let error):
//                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self?.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }

    private func getUsersList2() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()
        IQAPIClient.getUsersList2 { [weak self] result in

            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let data):
                self?.users = data.data
                self?.refreshUI()
            case .failure(let error):
//                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self?.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }

    private func getUsersList3() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()
        IQAPIClient.getUsersList3 { [weak self] result in

            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let response):

                let list = response["data"] as? [[String:Any]] ?? []
                var users = [User]()
                for user in list {
                    users.append(User(attributes:user))
                }

                self?.users = users
                self?.refreshUI()
            case .failure(let error):
//                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self?.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }

    private func getUsersList4() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()

        var parameters = [String: Any]()
        parameters["page_index"] = 1
        parameters["page_size"] = 2
        parameters["paramter_2"] = "something"

        let image = UIImage()
        let imageData = image.jpegData(compressionQuality: 1.0)!
        let file = UploadableFile(data: imageData, mimeType: "image/jpeg", fileName: "profile_picture.jpg")
        parameters["profile_picture"] = file

        IQAPIClient.sendRequest(path: ITAPIPath.users.rawValue, method: .post, parameters: parameters) { [weak self] (result: IQAPIClient.Result<UserResponse<[User]>, [String:Any]>) in

            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let data):
                self?.users = data.data
                self?.refreshUI()
            case .failure(let response):
                let alertController = UIAlertController(title: "Failed", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                print(response)
            case .error(let error):
//                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self?.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }

    private func getUsersList5() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()
        IQAPIClient.sendRequest(path: ITAPIPath.users.rawValue) { [weak self] (result: Swift.Result<[String:Any], Error>) in

            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let response):

                let list = response["data"] as? [[String:Any]] ?? []
                var users = [User]()
                for user in list {
                    users.append(User(attributes: user))
                }

                self?.users = users
                self?.refreshUI()
            case .failure(let error):
//                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self?.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }

    @IBAction func clear(_ sender: UIBarButtonItem) {
        users = []
        refreshUI()
    }

    @IBAction func refresh1(_ sender: UIBarButtonItem) {
        getUsersList1()
    }

    @IBAction func refresh2(_ sender: UIBarButtonItem) {
        getUsersList2()
    }

    @IBAction func refresh3(_ sender: UIBarButtonItem) {
        getUsersList3()
    }

    @IBAction func refresh4(_ sender: UIBarButtonItem) {
        getUsersList4()
    }

    @IBAction func refresh5(_ sender: UIBarButtonItem) {
        getUsersList5()
    }

    func refreshUI() {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

