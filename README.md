#  Публикация и использование SDK

Принцип хорошо показан в:
https://www.raywenderlich.com/17753301-creating-a-framework-for-ios

1. Изменить значения в Build Settings:
 - Build Options>Build Libraries for Distribution      Yes
 - Deployment>Installation Directory                   Library/Frameworks

После этого открыть терминал в корневой директории

**ВАЖНО**
Для тестирования библиотеки с использованием  ios-sdk-demo параметр
 - Build Options>Build Libraries for Distribution
 должен быть установлен     **NO**

2. Создать фреймворк для iOS 
**************** For iOS ****************
xcodebuild archive \
-scheme ios-sdk \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/ios-sdk.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

3. Создать фреймворк для эмулятора
**************** For simulator ****************
xcodebuild archive \
-scheme ios-sdk \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/ios-sdk.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

4. Собрать все в общий фреймворк
************ XCFramework ****************
xcodebuild -create-xcframework \
-framework './build/ios-sdk.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/ios_sdk.framework' \
-framework './build/ios-sdk.framework-iphoneos.xcarchive/Products/Library/Frameworks/ios_sdk.framework' \
-output './build/ios-sdk.xcframework'

5. Скопировать папку ios-sdk.xcframework из ./build в ./SwiftPackage/ios-sdk/Framework

6. Опубликовать (если требуется) папку ios-sdk в GitHub. Возможно, она должна быть public

7. ВАЖНО!!!
В файле README ios-sdk (там, где находится Package.swift) указать реальный URL репозитория!
