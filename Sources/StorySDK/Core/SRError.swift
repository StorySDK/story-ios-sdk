//
//  SRError.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

import Foundation

public enum SRError: Error, LocalizedError {
    case noAppsToDisplay
    case emptyResponse
    case serverError(String?)
    case wrongFormat
    case unknownError
    case missingDocumentsDirectory
    
    // MARK: - Parser errors
    case unknownColor(String)
    case unknownType
    
    public var errorDescription: String? {
        switch self {
        case .noAppsToDisplay:
            return "You don't have apps to display"
        case .emptyResponse:
            return "Data is empty"
        case .serverError(let info):
            return info.map { "Error response: \($0)" } ?? "Error response"
        case .wrongFormat:
            return "Wrong response format"
        case .unknownError:
            return "Unknown error"
        case .missingDocumentsDirectory:
            return "Can't find documents directory"
        case .unknownColor(let color):
            return "Unknown color format (\(color))"
        case .unknownType:
            return "Unknown response format"
        }
    }
}
