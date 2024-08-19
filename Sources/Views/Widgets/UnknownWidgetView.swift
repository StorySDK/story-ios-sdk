//
//  UnknownWidgetView.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 14.05.2023.
//

#if os(macOS)
    import Cocoa

    class UnknownWidgetView: SRInteractiveWidgetView {
        let widget: SRUnknownWidget
        
        init(story: SRStory, data: SRWidget, widget: SRUnknownWidget) {
            self.widget = widget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    class UnknownWidgetView: SRInteractiveWidgetView {
        let widget: SRUnknownWidget
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, widget: SRUnknownWidget) {
            self.widget = widget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data)
        }
        
        override func setupView() {
            super.setupView()
            backgroundColor = .clear
        }
    }
#endif
