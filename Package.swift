// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StorySDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "StorySDK",
            targets: ["StorySDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StorySDK",
            path: "Sources",
            resources: [
                .process("Resources"),
                .process("PrivacyInfo.xcprivacy"),
            ]),
    ]
)
