IQAPIClient
==========================
Model driven API Client

[![Build Status](https://travis-ci.org/hackiftekhar/IQAPIClient.svg)](https://travis-ci.org/hackiftekhar/IQAPIClient)

IQAPIClient allows us to make API requests and get back the responses in your defined model objects.

## Requirements
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()

| Library                | Language | Minimum iOS Target | Minimum Xcode Version |
|------------------------|----------|--------------------|-----------------------|
| IQAPIClient            | Swift    | iOS 10.0           | Xcode 11              |

#### Swift versions support
5.0 and above

Installation
==========================

#### Installation with CocoaPods

[![CocoaPods](https://img.shields.io/cocoapods/v/IQAPIClient.svg)](http://cocoadocs.org/docsets/IQAPIClient)

IQAPIClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQAPIClient'
```

*Or you can choose the version you need based on the Swift support table from [Requirements](README.md#requirements)*

```ruby
pod 'IQAPIClient', '1.0.0'
```

#### Installation with Source Code

[![Github tag](https://img.shields.io/github/tag/hackiftekhar/IQAPIClient.svg)]()

***Drag and drop*** `IQAPIClient` directory from demo project to your project

#### Installation with Swift Package Manager

[Swift Package Manager(SPM)](https://swift.org/package-manager/) is Apple's dependency manager tool. It is now supported in Xcode 11. So it can be used in all appleOS types of projects. It can be used alongside other tools like CocoaPods and Carthage as well. 

To install IQAPIClient package into your packages, add a reference to IQAPIClient and a targeting release version in the dependencies section in `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    products: [],
    dependencies: [
        .package(url: "https://github.com/hackiftekhar/IQAPIClient.git", from: "1.0.0")
    ]
)
```

To install IQAPIClient package via Xcode

 * Go to File -> Swift Packages -> Add Package Dependency...
 * Then search for https://github.com/hackiftekhar/IQAPIClient.git
 * And choose the version you would like

Basic Configuration
==========================

Well, we'll have to do an initial configuration before using IQAPIClient like setting your API base urls and default headers etc. You can do it in your AppDelegate.


```swift
        IQAPIClient.baseURL = URL(string: "https://www.example.com/api/v1")
        IQAPIClient.httpHeaders["Content-Type"] = "application/json"
        IQAPIClient.httpHeaders["Accept"] = "application/json"
```

Configure our Model
==========================

Now let's say you have an API which returns the list of users and you have a User model for that.

```swift
struct User {

    let id: Int

    let name: String

    let email: String?
}
```

Now first, we need to modify our model to make it compatible to the IQAPIClient. To do this, we only have to confirm our User Model with the Decodable protocol and that's it.

```swift
// Now it's ready to be used with IQAPIClient
struct User: Decodable {

    let id: Int

    let name: String

    let email: String?
}
```

IQAPIClient Basic Method Signatures
==========================

#### Swift.Result version

```swift
static func sendRequest<Success>(
            path: String,
            method: HTTPMethod = .get,
            parameters: Parameters? = nil,
            completionHandler: @escaping
            (_ result: Swift.Result<Success, Error>) -> Void)
```

where native **Swift.Result** looks like this
```swift
enum Result<Success, Failure> where Failure: Error {
    case success(Success)	/// A success, storing a `Success` value.
    case failure(Failure)	/// A failure, storing a `Failure` value.
}
```

#### IQAPIClient.Result version

```swift
static func sendRequest<Success, Failure>(
            path: String,
            method: HTTPMethod = .get,
            parameters: Parameters? = nil,
            completionHandler: @escaping 
            (_ result: IQAPIClient.Result<Success, Failure>) -> Void)
```

where **IQAPIClient.Result** looks like this
```swift
enum Result<Success, Failure> {
    case success(Success)	/// A success, storing a `Success` value.
    case failure(Failure)	/// A failure, storing a `Failure` value.
    case error(Error)		/// An error, storing an `Error` value.
}
```

API call using IQAPIClient
==========================

To get list of users, there are a couple of ways you could use IQAPIClient.

#### Method 1: Directly using the sendRequest method (Swift.Result version)

```swift
class ViewController: UIViewController {

    private func getUsersList() {
        //Result<[User], NSError> detects that the app is asking for array of User object
        IQAPIClient.sendRequest(path: "/users") { [weak self] (result: Swift.Result<[User], NSError>) in
            switch result {
            case .success(let users):
                self?.users = users
                self?.refreshUI()
            case .failure(let error):
                //Show error alert
                print(error.localizedDescription)
            }
        }
    }
}
```

#### Method 2: Same request but with IQAPIClient.Result version

Let's say APIMessage looks like below and we get this kind of response when something goes wrong

```swift
struct APIMessage: Decodable {
    let status: Bool
    let code: Int
    let message: String
}
```

```swift
class ViewController: UIViewController {

    private func getUsersList() {
        //Result<[User], NSError> detects that the app is asking for array of User object
        IQAPIClient.sendRequest(path: "/users") { [weak self] (result: Swift.Result<[User], APIMessage>) in
            switch result {
            case .success(let users):   //[User] object
                self?.users = users
                self?.refreshUI()
            case .failure(let message): //APIMessage object
                //Show failure alert
                print(message.code)
                print(message.message)
            case .error(let error):     //Error object
                //Show error alert
                print(error.localizedDescription)
            }
        }
    }
}
```

#### Method 2: Moving this call to a function in IQAPIClient extension

```swift
extension IQAPIClient {

    @discardableResult
    static func getUsersList(completionHandler: @escaping (_ result: Swift.Result<User, NSError>) -> Void) -> DataRequest {
        return sendRequest(path: "/users", completionHandler: completionHandler)
    }
}
```

#### Method 3: If you don't have a Model yet, then you could also get the response in the form of Array of Dictionary like below:-

```swift
extension IQAPIClient {

    @discardableResult
    static func getUsersList(completionHandler: @escaping (_ result: Swift.Result<[[String:Any]], NSError>) -> Void) -> DataRequest {
        return sendRequest(path: "/users", completionHandler: completionHandler)
    }
}

class ViewController: UIViewController {

    private func getUsersList() {
        
        //Now use the getUsersList function
        IQAPIClient.getUsersList { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
                self?.refreshUI()
            case .failure(let error):
                //Show error alert
                print(error.localizedDescription)
            }
        }
    }
}
```

Advance Configuration
==========================

### Advance paramters of sendRequest method
```
- successSound: Bool = false  //A success sound/vibration will be played on success response, you could use it when you create some records like saving something in the server.
- failedSound: Bool = false   //An error sound/vibration will be played on error 
- executeErroHandlerOnError: Bool = true  //This will also execute common error handler block on error to handle all error from a single place.
```
//TODO to add examples

LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email me: hack.iftekhar@gmail.com
