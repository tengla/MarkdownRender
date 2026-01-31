// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkdownRender",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "MarkdownRender",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "MarkdownRenderTests",
            dependencies: [
                "MarkdownRender",
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
    ]
)
