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

class SRLogger {
    var logLevel: OSLogType = .error
    
    init() {}
    
    func debug(_ message: String, logger: OSLog = .general) {
        guard logLevel <= .debug else { return }
        os_log("%@", log: logger, type: .debug, message)
    }

    func error(_ message: String, logger: OSLog = .general) {
        guard logLevel <= .error else { return }
        os_log("%@", log: logger, type: .error, message)
    }
}

func <=(_ lhs: OSLogType, _ rhs: OSLogType) -> Bool {
    lhs.rawValue <= rhs.rawValue
}
