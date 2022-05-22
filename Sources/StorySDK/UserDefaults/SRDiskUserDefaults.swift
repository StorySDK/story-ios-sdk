//
//  SRDiskUserDefaults.swift
//  
//
//  Created by Aleksei Cherepanov on 22.05.2022.
//

import Foundation

public class SRDiskUserDefaults: SRMemoryUserDefaults {
    private let manager = FileManager.default
    private let fileUrl: URL
    let key: String
    
    init(key: String) throws {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw SRError.missingDocumentsDirectory
        }
        url.appendPathComponent(packageBundleId, isDirectory: true)
        self.key = key
        self.fileUrl = url.appendingPathComponent(key).appendingPathExtension("plist")
        super.init()
        try prepareDirectory(baseUrl: url)
        try load()
    }
    
    private func prepareDirectory(baseUrl: URL) throws {
        if let isDirectory = (try? baseUrl.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory {
            guard !isDirectory else { return }
            try manager.removeItem(at: baseUrl)
        }
        try manager.createDirectory(at: baseUrl, withIntermediateDirectories: false)
    }
    
    func load() throws {
        guard manager.fileExists(atPath: fileUrl.path) else { return }
        let decoder = PropertyListDecoder()
        let data = try Data.init(contentsOf: fileUrl)
        model = try decoder.decode(SRUserDefaultsModel.self, from: data)
    }
    
    func save() throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(model)
        try data.write(to: fileUrl)
    }
    
    public override func didPresent(group: String) {
        super.didPresent(group: group)
        do {
            try save()
        } catch {
            print("StorySDK.DiskUserDefaults > Error:", error.localizedDescription)
        }
    }
}

import CommonCrypto
extension SRDiskUserDefaults {
    /// Makes SHA256 hash sum
    static func makeKey(sdkId value: String) -> String? {
        guard let data = value.data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { CC_SHA256($0.baseAddress, UInt32($0.count), &hash) }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
