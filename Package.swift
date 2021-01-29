import PackageDescription

let package = Package(
    name: "IQAPIClient",
    products: [
       .library(name: "IQAPIClient", targets: ["IQAPIClient"])
   ],
   targets: [
       .target(
           name: "IQAPIClient",
           path: "IQAPIClient"
       )
   ]
)
