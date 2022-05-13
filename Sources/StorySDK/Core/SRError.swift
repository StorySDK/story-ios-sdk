//
//  SRError.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

import Foundation

public enum SRError: Error, LocalizedError {
    case sdkIdIsNill
    case noAppsToDisplay
    case emptyResponse
    case serverError(String?)
    case wrongFormat
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .sdkIdIsNill:
            return "SDK id is nil"
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
        }
    }
}
