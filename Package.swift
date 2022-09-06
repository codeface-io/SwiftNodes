// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftNodes",
    platforms: [.iOS(.v12), .tvOS(.v12), .macOS(.v10_15)],
    products: [
        .library(
            name: "SwiftNodes",
            targets: ["SwiftNodes"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.2"
        )
    ],
    targets: [
        .target(
            name: "SwiftNodes",
            dependencies: [
                "SwiftyToolz",
                .product(name: "OrderedCollections",
                         package: "swift-collections"),
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
