// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SubscriberVapor",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SubscriberVapor",
            targets: ["SubscriberVapor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/WebSubKit/SubscriberKit.git", from: "1.1.0"),
        .package(url: "https://github.com/WebSubKit/SubscriberFluent.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "SubscriberVapor",
            dependencies: [
                .product(name: "SubscriberFluent", package: "SubscriberFluent"),
                .product(name: "SubscriberKit", package: "SubscriberKit"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent")
            ]
        )
    ]
)
