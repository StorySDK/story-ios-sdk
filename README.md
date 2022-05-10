# StorySDK

[![CI Status](https://img.shields.io/travis/StorySDK/StorySDK.svg?style=flat)](https://travis-ci.org/StorySDK/StorySDK)
[![Version](https://img.shields.io/cocoapods/v/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)
[![License](https://img.shields.io/cocoapods/l/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)
[![Platform](https://img.shields.io/cocoapods/p/StorySDK.svg?style=flat)](https://cocoapods.org/pods/StorySDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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

### Add Story SDK
Make sure to import the project wherever you may use it:

```swift
import StorySDK
```

**TIP**
Please do not forget to use your own token. You can get your token from the StorySDK Dashboard -> Settings (https://app.diffapp.link/dashboard/)

1. Setup preffered language

```swift
private var preferredStoryLanguage = String(Locale.preferredLanguages[0].prefix(2))
```

2. Prepare variables:

```swift
private let sdkId = "[YOUR_SDK_ID]"

private var storySDK: StorySDK!
private var storyApp: StoryApp!
private var groups = [StoryGroup]()

private var defaultStoryLanguage = "en"
```

3. Init StorySDK

```swift
self.storySDK = StorySDK(sdkId, userID: userId, preferredLanguage: preferredStoryLanguage)
```

### Use StorySDK

1. Get AppID for your SDK ID

```swift
storySDK.getApps(completion: { error, app in
    if let error = error { return } // Actions for error
    guard let app = app else { return } // Unknown error
    self.storyApp = app
    self.defaultStoryLanguage = app.localization.default_locale
    self.storySDK.setDefaultLanguage(self.defaultStoryLanguage)
    // Additional actions if needed
})
```

2. Get groups for selected app

```swift
storySDK.getGroups(appID: storyApp.id, statistic: true / false, completion: { error, result in
    if let error = error { return } // Actions for error
    guard let result = result else { return } // Unknown error
    self.groups = result
    // Additional actions if needed
})
```

3. Show selected group using top view controller

```swift
storySDK.getStories(group, statistic: true / false, completion: { error, result in
    DispatchQueue.main.async { [self] in
        if let error = error { return } // Actions for error
        guard let result = result else { return }
        guard result.count > 0 else { return } // No active stories!!!
        let storyViewController = StoriesViewController(result, for: group, activeOnly: true / false)
        self.present(storyViewController, animated: true, completion: nil)
    }
})
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
storySDK.setProgressDuration(10)
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
