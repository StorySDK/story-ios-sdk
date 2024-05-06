//
//  Defines.swift
//  StorySDK
//
//  Created by Igor Efremov on 11.07.2023.
//

#if os(macOS)
    import Cocoa
    public typealias StoryColor = NSColor
    public typealias StoryImage = NSImage
    public typealias StoryFont = NSFont
    public typealias StoryView = NSView
    public typealias StoryButton = NSButton
    public typealias StoryControl = NSControl
    public typealias StoryViewController = NSViewController
    public typealias StoryFontDescriptor = NSFontDescriptor
    public typealias StoryScreen = NSScreen
    public typealias StoryContentMode = Int
    public typealias StoryWorkspace = NSWorkspace

    public struct StoryViewContentMode {
        public static let scaleAspectFill = 2
    }

    public extension StoryColor {
        static var systemBackgroundColor: StoryColor {
            return NSColor.windowBackgroundColor
        }
    }

    public extension StoryImage {
        func pngImageData() -> Data? {
            return nil
        }
    }

    public extension StoryScreen {
        static var screenScale: CGFloat {
            return NSScreen.main?.backingScaleFactor ?? 1.0
        }
        
        static var screenBounds: NSRect {
            return NSScreen.main?.frame ?? .zero
        }
        
        static var screenNativeScale: CGFloat {
            return NSScreen.main?.backingScaleFactor ?? 1.0
        }
    }

    public extension StoryWorkspace {
        func canOpen(_ url: URL) -> Bool {
            return false
        }
    }
#elseif os(iOS)
    import UIKit
    public typealias StoryColor = UIColor
    public typealias StoryImage = UIImage
    public typealias StoryFont = UIFont
    public typealias StoryView = UIView
    public typealias StoryButton = UIButton
    public typealias StoryControl = UIControl
    public typealias StoryViewController = UIViewController
    public typealias StoryFontDescriptor = UIFontDescriptor
    public typealias StoryScreen = UIScreen
    public typealias StoryContentMode = UIView.ContentMode
    public typealias StoryWorkspace = UIApplication

    public struct StoryViewContentMode {
        public static let scaleAspectFill = UIView.ContentMode.scaleAspectFill
    }

    public extension StoryColor {
        static var systemBackgroundColor: StoryColor {
            return UIColor.systemBackground
        }
    }

    public extension StoryImage {
        func pngImageData() -> Data? {
            return pngData()
        }
    }

    public extension StoryScreen {
        static var screenScale: CGFloat {
            return UIScreen.main.scale
        }
        
        static var screenBounds: CGRect {
            return UIScreen.main.bounds
        }
        
        static var screenNativeScale: CGFloat {
            return UIScreen.main.nativeScale
        }
    }

    public extension StoryWorkspace {
        func canOpen(_ url: URL) -> Bool {
            return canOpenURL(url)
        }
    }
#endif
