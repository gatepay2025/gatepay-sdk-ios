// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GateOpenPaySDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "GateOpenPaySDK",
            targets: ["GateOpenPaySDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "GateOpenPaySDK",
            url: "https://github.com/gatepay2025/gatepay-sdk-ios/releases/GateOpenPaySDK-2.0.0.xcframework.zip",
            checksum: "53806338bcd6a2f0de71a45bfc49fc7a3efeb9c84d868cf2b9d250216a59bad8"
        )
    ]
)
