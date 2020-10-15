//
//  AppDelegate.swift
//  API Client
//
//  Created by Iftekhar on 09/09/20.
//  Copyright © 2020 Iftekhar. All rights reserved.
//

import UIKit
import IQAPIClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureAPIClienthandlers()
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func configureAPIClienthandlers() {

        func topViewController() -> UIViewController? {
            var parentController = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
            while parentController != nil, let newParent = parentController?.presentedViewController  {
                parentController = newParent
            }
            return parentController
        }

        IQAPIClient.baseURL = URL(string: "https://www.example.com/api/v1")
        IQAPIClient.httpHeaders["Content-Type"] = "application/json"
        IQAPIClient.httpHeaders["Accept"] = "application/json"

        //Common error handler block is common for all requests, so we could just write UIAlertController presentation logic at single place for showing error from any API response.
        IQAPIClient.commonErrorHandlerBlock = { (request, requestParameters, responseData, error) in

            switch error.code {
            case NSURLClientError.unauthorized401.rawValue:

                let window: UIWindow?
                #if swift(>=5.1)
                if #available(iOS 13, *) {
                    window = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first(where: { $0.isKeyWindow })
                } else {
                    window = UIApplication.shared.keyWindow
                }
                #else
                window = UIApplication.shared.keyWindow
                #endif

                window?.rootViewController?.dismiss(animated: true, completion: nil)

            default:
                let alertController = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                topViewController()?.present(alertController, animated: true, completion: nil)
            }
        }

        //We have below structure of API response, and usually I'm only interested in "data" field so I implemented the responseModifierBlock according to the below response
        /*
         Success
         {
            "status": 200,
            "data": {
                "id":4,
                "name":"Some name"
            }
         }
         */

        /*
         Success
         {
            "status": 200,
            "message": "We have successfully sent you an email with instructions to reset your password."
         }
         */

        /*
         Error
         {
            "status": 400,
            "message": "Something went wrong"
         }
         */

        IQAPIClient.responseModifierBlock = { (request, response) in

            guard let status = response["status"] as? Int else {
                let error = NSError(domain: "ServerError", code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: IQAPIClient.unintentedResponseErrorMessage])
               return .failure(error)
            }

            if let data = response["data"] as? [String:Any] {
                return .success(data)
            } else {
                let message = response["message"] as? String ?? ""

                if status >= NSURLClientError.badRequest400.rawValue {
                    let error = NSError(domain: "ServerError", code: status, userInfo: [NSLocalizedDescriptionKey:message])
                    return .failure(error)
                } else {
                    return .success(response)
                }
            }
        }
    }
}

