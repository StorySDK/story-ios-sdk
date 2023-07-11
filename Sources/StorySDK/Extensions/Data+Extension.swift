//
//  Data+Extension.swift
//  StoriesPlayer
//
//  Created by Igor Efremov on 10.07.2023.
//

import Foundation
import CommonCrypto

public extension Data {
    func hex() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    func sha256() -> Data {
        let digest = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))!
        let value = self as NSData
        let uint8Pointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: digest.length)
        CC_SHA256(value.bytes, CC_LONG(self.count), uint8Pointer.baseAddress)
        return Data(buffer: uint8Pointer)
    }
}

