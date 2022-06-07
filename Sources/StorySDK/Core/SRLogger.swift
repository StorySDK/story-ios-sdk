//
//  SRLogger.swift
//  
//
//  Created by Aleksei Cherepanov on 07.06.2022.
//

import Foundation
import os

extension OSLog {
    static let general = OSLog(subsystem: "StorySDK", category: "General")
    static let stories = OSLog(subsystem: "StorySDK", category: "StoriesVC")
    static let imageCache = OSLog(subsystem: "StorySDK", category: "ImageCache")
    static let userDefaults = OSLog(subsystem: "StorySDK", category: "UserDefaults")
    static let widgets = OSLog(subsystem: "StorySDK", category: "WidgetView")
}

func debug(_ message: String, logger: OSLog = .general) {
    os_log("%@", log: logger, type: .debug, message)
}

func logError(_ message: String, logger: OSLog = .general) {
    os_log("%@", log: logger, type: .error, message)
}
