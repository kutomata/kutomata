// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Kutomata",
    products: [
        .library(
            name: "Kutomata",
            targets: ["Kutomata"]),
    ],
    targets: [
        .target(
            name: "Kutomata"),
        .testTarget(
            name: "KutomataTests",
            dependencies: ["Kutomata"]
        ),
    ]
)
