# StorySDK

[![Version](https://img.shields.io/cocoapods/v/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)
[![License](https://img.shields.io/cocoapods/l/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)
[![Platform](https://img.shields.io/cocoapods/p/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)

iOS Framework for the StorySDK service for creating and adding stories to mobile apps 



## Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/StorySDK/ios-sdk.git`
- Select "Up to Next Major" with "1.0.0"

#### CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  pod 'StorySDK', '~> 1.0'
end
```

#### Carthage

```
github "StorySDK/ios-sdk" ~> 1.0
```

## Usage

### Import SDK

Make sure to import the project wherever you may use it:

```swift
import StorySDK
```

### Setup

To use SDK you need token from StorySDK Dashboard > Settings [https://app.diffapp.link/dashboard/](https://app.diffapp.link/dashboard/)

```swift
storySdk.configuration.sdkId = "[YOUR_SDK_ID]"
```

#### Optional

To track users you need to declare unique user id. And keep it between the app runtimes. You can save it to UserDefaults for example.

```swift
let userId: String
if let id = UserDefaults.standard.string(forKey: "[YOUR_USER_ID_KEY]") {
    userId = id
} else {
    let id = UUID().uuidString
    UserDefaults.standard.set(id, forKey: "[YOUR_USER_ID_KEY]")
    userId = id
}
```

```swift
storySdk.configuration.userId = userId
```

Also you can define language for the stories. 

```swift
storySdk.configuration.language = "en"
```

#### TLDR

```swift
StorySDK.shared.configuration.sdkId = "[YOUR_SDK_ID]"
StorySDK.shared.configuration.userId = "[YOUR_USER_ID]"
```

### UI Integration

You can use Groups Widget to display groups of stories in your app. 

```swift
let widget = SRStoryWidget()
addSubview(widget)
```

When your app will be ready to load groups just call `widget.load()`. You can process errors and taps on a group by implementing Delegate protocol `SRStoryWidgetDelegate` and put it to `widget.delegate`.

### Direct API

To get SDK application info

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

To get groups of the app

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

Show selected group using top view controller

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
