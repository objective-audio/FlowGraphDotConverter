// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowGraphDotConverter",
    products: [
        .executable(name: "FlowGraphDotConverter", targets: ["FlowGraphDotConverter"]),
        .library(name: "FlowGraphDotConverterCore", targets: ["FlowGraphDotConverterCore"]),
        ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.23.1"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/objective-audio/SwiftFlowGraph.git", from: "0.6.2"),
    ],
    targets: [
        .target(
            name: "FlowGraphDotConverter",
            dependencies: ["FlowGraphDotConverterCore", "Commander"]),
        .target(
            name: "FlowGraphDotConverterCore",
            dependencies: ["SourceKittenFramework", "FlowGraph"]),
    ]
)
