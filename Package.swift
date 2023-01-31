// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "SwiftNodes",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(
            name: "SwiftNodes",
            targets: ["SwiftNodes"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            exact: "0.3.0"
        )
    ],
    targets: [
        .target(
            name: "SwiftNodes",
            dependencies: [
                "SwiftyToolz"
            ],
            path: "Code"
        ),
        .testTarget(
            name: "SwiftNodesTests",
            dependencies: ["SwiftNodes", "SwiftyToolz"],
            path: "Tests"
        ),
    ]
)
