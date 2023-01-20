// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "IQAPIClient",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "IQAPIClient", targets: ["IQAPIClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "IQAPIClient", dependencies: ["Alamofire"], path: "IQAPIClient")
    ]
)
