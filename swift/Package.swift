// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "heliumd",
    products: [
        .library(
            name: "ObjCWacom",
            targets: ["ObjCWacom"])
    ],
    targets: [
        .target(name: "ObjCWacom",
                dependencies: [],
                path: "Sources/Wacom",
                exclude: [],
                sources: ["."],
                publicHeadersPath: "include")
    ])

// .executableTarget(name: "heliumd", dependencies: ["ObjCWacom"], path: "Sources"),
// .executable(
//     name: "heliumd",
//     targets: ["heliumd"])
