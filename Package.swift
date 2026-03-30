// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TimeLeft",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TimeLeft", targets: ["TimeLeft"])
    ],
    targets: [
        .executableTarget(
            name: "TimeLeft"
        ),
        .testTarget(
            name: "TimeLeftTests",
            dependencies: ["TimeLeft"]
        )
    ]
)
