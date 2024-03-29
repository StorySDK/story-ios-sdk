//
//  DiskImageCache.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation
#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

final class DiskImageCache: ImageCache {
    private let rootDir: URL = FileManager.default.temporaryDirectory.appendingPathComponent(packageBundleId, isDirectory: true)
    private let queue = DispatchQueue(label: packageBundleId + ".DiskImageCache")
    private let logger: SRLogger
    
    init(logger: SRLogger) throws {
        self.logger = logger
        try prepareDirectory()
    }
    
    func hasImage(_ key: String) -> Bool {
        guard let url = fileUrl(key) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func loadImage(_ key: String) -> StoryImage? {
        guard let url = fileUrl(key) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return StoryImage(data: data)
        } catch {
            logger.error(error.localizedDescription, logger: .imageCache)
            return nil
        }
    }
    
    func saveImage(_ key: String, image: StoryImage) {
        guard let url = fileUrl(key) else { return }
        queue.async { [logger] in
            do {
                try image.pngImageData()?.write(to: url)
            } catch {
                logger.error(error.localizedDescription, logger: .imageCache)
            }
        }
    }
    
    func removeImage(_ key: String) {
        guard let url = fileUrl(key) else { return }
        queue.async { [logger] in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                logger.error(error.localizedDescription, logger: .imageCache)
            }
        }
    }
    
    func removeAll() {
        guard let filenames = try? FileManager.default.contentsOfDirectory(atPath: rootDir.path) else { return }
        let urls = filenames.map { rootDir.appendingPathComponent($0) }
        for url in urls {
            queue.async { [logger] in
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    logger.error(error.localizedDescription, logger: .imageCache)
                }
            }
        }
    }
    
    private func fileUrl(_ key: String) -> URL? {
        guard let filename = key.data(using: .utf8)?.base64EncodedString() else { return nil }
        return rootDir.appendingPathComponent(filename, isDirectory: false)
    }
    
    private func prepareDirectory() throws {
        let manager = FileManager.default
        if let isDirectory = (try? rootDir.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory {
            guard !isDirectory else { return }
            try manager.removeItem(at: rootDir)
        }
        try manager.createDirectory(at: rootDir, withIntermediateDirectories: false)
    }
}
