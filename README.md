# StorySDK

[![CI Status](https://img.shields.io/travis/StorySDK/StorySDK.svg?style=flat)](https://travis-ci.org/StorySDK/StorySDK)
[![Version](https://img.shields.io/cocoapods/v/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)
[![License](https://img.shields.io/cocoapods/l/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)
[![Platform](https://img.shields.io/cocoapods/p/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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

To use SDK you need token from StorySDK Dashboard -> Settings (https://app.diffapp.link/dashboard/)

```swift
StorySDK.shared.configuration.sdkId = "[YOUR_SDK_ID]"
```

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
StorySDK.shared.configuration.userId = userId
```

*Optional*. Also you can define language for the stories. 

```swift
StorySDK.shared.configuration.language = "en"
```

#### TLDR

```swift
StorySDK.shared.configuration.sdkId = "[YOUR_SDK_ID]"
StorySDK.shared.configuration.userId = "[YOUR_USER_ID]"
```

### UI Integration


1. Get AppID for your SDK ID

```swift
storySDK.getApps { [weak self] result in
    switch result {
    case .success(let app):
        self?.storyApp = app
        // Additional actions if needed
    case .failure(let error):
        // Actions for error
        break
    }
}
```

2. Get groups for selected app

```swift
storySDK.getGroups(appId: storyApp.id) { [weak self] result in
    switch result {
    case .success(let groups):
        self?.groups = groups
        // Additional actions if needed
    case .failure(let error):
        // Actions for error
        break
    }
}
```

3. Show selected group using top view controller

```swift
storySDK.getStories(group) { [weak self] result in
    DispatchQueue.main.async { [self] in
	     switch result {
	     case .success(let stories):
	         guard !stories.isEmpty else { break } // No active stories
	         // Present stories
	     case .failure(let error):
	         // Actions for error
	         break
	     }
    }
}
```

**TIPS**

a) Set full screen on / off

```swift
storySDK.setFullScreen(true / false)
```

b) Show title on / off

```swift
storySDK.setTitleEnabled(true / false)
```

c) Set show time duration for each story

```swift
storySDK.configuration.storyDuration = 10
```

d) Set progress color

```swift
storySDK.setProgressColor(UIColor.green)
```

e) Change preffered language

```swift
storySDK.changePrefferedLanguage("en")
```

## License

StorySDK is available under the MIT license. See the LICENSE file for more info.
