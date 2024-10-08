//
//  SRPositionByResolutions.swift
//  
//
//  Created by Ingvarr Alef on 09/09/2023.
//

import Foundation

public struct SRPositionByResolutions: Decodable {
    public var res360x640: SRPosition?
    public var res360x780: SRPosition?
    
    enum CodingKeys: String, CodingKey {
        case res360x640 = "360x640"
        case res360x780 = "360x780"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var decodeError: Error?
        do {
            res360x640 = try container.decode(SRPosition.self, forKey: .res360x640)
        } catch {
            decodeError = error
        }
        do {
            res360x780 = try container.decode(SRPosition.self, forKey: .res360x780)
        } catch {
            decodeError = error
        }
        guard res360x640 == nil && res360x780 == nil else { return }
        let error = decodeError ?? DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Empty position object"))
        throw error
    }
}
