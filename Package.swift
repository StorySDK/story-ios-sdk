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
            resources: [
                .copy("Resources/Images/confetti.png"),
                .copy("Resources/Images/logo.png"),
                .copy("Resources/Fonts/Inter/Inter-Bold.ttf"),
                .copy("Resources/Fonts/Inter/Inter-Regular.ttf"),
                .copy("Resources/Fonts/Inter/Inter-SemiBold.ttf"),
                .copy("Resources/Fonts/Inter/Inter-Medium.ttf"),
                .copy("Resources/Fonts/Roboto/Roboto-Bold.ttf"),
                .copy("Resources/Fonts/Roboto/Roboto-Regular.ttf"),
                .copy("Resources/Fonts/Roboto/Roboto-Medium.ttf"),
                .copy("Resources/Fonts/Roboto/Roboto-Light.ttf"),
                .copy("Resources/Fonts/Montserrat/Montserrat-Bold.ttf"),
                .copy("Resources/Fonts/SFCompactRounded/SF-Compact-Rounded-Regular.otf"),
                .copy("Resources/Fonts/SFCompactRounded/SF-Compact-Rounded-Bold.ttf")
            ]),
    ]
)
