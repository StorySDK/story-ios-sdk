//
//  File.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation
import UIKit

final class DiskImageCache: ImageCache {
    private let rootDir: URL = FileManager.default.temporaryDirectory.appendingPathComponent(packageBundleId, isDirectory: true)
    private let queue = DispatchQueue(label: packageBundleId + ".DiskImageCache")
    
    init() throws {
        try prepareDirectory()
    }
    
    func hasImage(_ key: String) -> Bool {
        guard let url = fileUrl(key) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func loadImage(_ key: String) -> UIImage? {
        guard let url = fileUrl(key) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            logError(error.localizedDescription, logger: .imageCache)
            return nil
        }
    }
    
    func saveImage(_ key: String, image: UIImage) {
        guard let url = fileUrl(key) else { return }
        queue.async {
            do {
                try image.pngData()?.write(to: url)
            } catch {
                logError(error.localizedDescription, logger: .imageCache)
            }
        }
    }
    
    func removeImage(_ key: String) {
        guard let url = fileUrl(key) else { return }
        queue.async {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                logError(error.localizedDescription, logger: .imageCache)
            }
        }
    }
    
    func removeAll() {
        guard let filenames = try? FileManager.default.contentsOfDirectory(atPath: rootDir.path) else { return }
        let urls = filenames.map { rootDir.appendingPathComponent($0) }
        for url in urls {
            queue.async {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    logError(error.localizedDescription, logger: .imageCache)
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
