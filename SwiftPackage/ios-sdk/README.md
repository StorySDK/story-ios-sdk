#  StorySDK

StorySDK for iOS

# Initial SDK Setup

### ⚙️ Installation

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into Xcode and the Swift compiler. **This is the recommended installation method.** Updates to StorySDK will always be available immediately to projects with SPM. SPM is also integrated directly with Xcode.

If you are using Xcode 11 or later:
 1. Click `File`
 2. `Swift Packages`
 3. `Add Package Dependency...`
 4. Specify the git URL for StorySDK.

```swift
https://github.com/.......git
```

## Add Story SDK
Make sure to import the project wherever you may use it:

```swift
import ios_sdk
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
        self.storySDK = StorySDK(sdkId, userID: String? = nil, preferredLanguage: preferredStoryLanguage)
```

## Use StorySDK
1. Get AppID for your SDK ID
```swift
        storySDK.getApps(completion: { error, app in
            if let error = error {
                //Actions for error
                return
            }
            if let app = app {
                self.storyApp = app
                self.defaultStoryLanguage = self.storyApp!.localization.default_locale
                self.storySDK.setDefaultLanguage(self.defaultStoryLanguage)
                //Additional actions if needed
            }
            else {
                //Unknown error
            }
        })
```

2. Get groups for selected app

```swift
        storySDK.getGroups(appID: storyApp.id, statistic: true / false, completion: { error, result in
            if let error = error {
                //Actions for error
                return
            }
            if let result = result {
                self.groups = result
                //Additional actions if needed
            }
            else {
                //Unknown error
            }
        })
```

3. Show selected group using top view controller

```swift
            storySDK.getStories(group, statistic: true / false, completion: { error, result in
                DispatchQueue.main.async { [self] in
                    if let error = error {
                //Actions for error
                        return
                    }
                    if let result = result {
                        if result.count > 0 {
                            let storyViewController = StoriesViewController(result, for: group, activeOnly: true / false)
                            self.present(storyViewController, animated: true, completion: nil)
                        }
                        else {
                            //No active stories!!!
                        }
                    }
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

