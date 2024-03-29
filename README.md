# StorySDK

[![GitHub release](https://img.shields.io/github/release/StorySDK/ios-sdk.svg)](https://github.com/StorySDK/ios-sdk/releases)
[![License](https://img.shields.io/github/license/StorySDK/ios-sdk.svg)](https://github.com/StorySDK/ios-sdk/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://github.com/StorySDK/ios-sdk)

### iOS Framework for the StorySDK Service

The StorySDK iOS Framework is a software development kit (SDK) for iOS app developers to integrate the StorySDK service into their mobile applications. The StorySDK service provides a platform for creating and adding stories to mobile apps.

By integrating the StorySDK iOS Framework into an iOS app, developers can add the following features:

- Display groups of stories using the Groups Widget
- Access the direct API to retrieve application information, groups, and stories
- Customize the configuration of the SDK, such as enabling full screen mode, showing/hiding the title, setting the duration for each story, and setting the progress color.

The StorySDK iOS Framework is available for installation via CocoaPods, Carthage, and Swift Package Manager. The framework is open source and available on GitHub, where developers can contribute to the development of the framework, report issues, and request new features.

### Why Use StorySDK?

The StorySDK service provides a platform for mobile app developers to create and add stories to their apps, which can increase user engagement and provide a more dynamic user experience. By integrating the StorySDK iOS Framework into an iOS app, developers can access the features of the StorySDK service without having to build the functionality from scratch, saving development time and effort.

The StorySDK service also provides a web-based dashboard for managing stories, which makes it easy for app developers to add and manage their app's stories. Additionally, the StorySDK service provides analytics on the usage of the stories, which can help app developers to measure the impact of their stories on user engagement.

## Installation

### Swift Package Manager

To install StorySDK using Swift Package Manager, follow these steps:

1. Open your project in Xcode and go to File > Swift Packages > Add Package Dependency.
2. In the search field, enter `https://github.com/StorySDK/ios-sdk.git` and click Next.
3. Select the version rule "Up to Next Major" and enter "1.0.0" in the text field.
4. Click Next and then Finish.

### CocoaPods

To install StorySDK using CocoaPods, add the following to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  pod 'StorySDK', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

#### Carthage

To install StorySDK using Carthage, add the following to your Cartfile:

```
github "StorySDK/ios-sdk" ~> 1.0
```

Then, run the following command:

```bash
$ carthage update
```

## Usage

### Import SDK

Make sure to import the project wherever you may use it:

```swift
import StorySDK
```

### Setup

To use the SDK, you need to obtain a token from the StorySDK dashboard. You can find your token in the Settings section of the dashboard at [https://app.storysdk.com/dashboard/](https://app.storysdk.com/dashboard/).

```swift
storySdk.configuration.sdkId = "[YOUR_SDK_ID]"
```

#### Optional

You can define language for the stories. 

```swift
storySdk.configuration.language = "en"
```

### UI Integration

You can use the Groups Widget to display groups of stories in your app. To add the widget to your view hierarchy:

```swift
let widget = SRStoryWidget()
addSubview(widget)
```

When your app is ready to load groups, call `widget.load()`. You can handle errors and taps on a group by implementing the `SRStoryWidgetDelegate`protocol and setting it as the widget's delegate.

### Direct API

To get information about the SDK application:

```swift
storySDK.getApps { result in
    switch result {
    case .success(let app):
        print(app)
    case .failure(let error):
        print("Error:", error.localizedDescription)
    }
}
```

To get the groups of the app:

```swift
storySDK.getGroups { result in
    switch result {
    case .success(let groups):
        print(groups)
    case .failure(let error):
        print("Error:", error.localizedDescription)
    }
}
```

To show the stories of a selected group using the top view controller:

```swift
storySDK.getStories(group) { [weak self] result in
    switch result {
    case .success(let stories):
        guard !stories.isEmpty else { break } // No active stories
        // Present stories
    case .failure(let error):
         print("Error:", error.localizedDescription)
    }
}
```

#### Configuration

a) Set full screen on / off

```swift
storySdk.configuration.needFullScreen = true / false
```

b) Show title on / off

```swift
storySdk.configuration.needShowTitle = true / false
```

c) Set show time duration for each story

```swift
storySdk.configuration.storyDuration = 10 // 10 seconds
```

d) Set progress color

```swift
storySdk.configuration.progressColor = .green
```

## License

StorySDK is available under the MIT license. See the LICENSE file for more info.
