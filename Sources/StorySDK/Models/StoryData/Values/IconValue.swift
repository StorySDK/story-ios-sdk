//
//  IconValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public enum SRIcon: Decodable {
    case arrowUpIcon
    case arrowheadUpOutlineIcon
    case arrowCircleUpOutlineIcon
    case arrowUpCircleIcon
    case arrowUpCircleFillIcon
    case arrowUpCircleLineIcon
    case iconChevronCircleUp
    case arrowUpFillIcon
    case arrowUpLineIcon
    case arrowUpOutlineIcon
    case arrowUpsFillIcon
    case arrowUpsLineIcon
    case linkIcon
    case linksLineIcon
    case shareLineIcon
    case uploadOutlineIcon
    case custom(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        switch name {
        case "ArrowUpIcon": self = .arrowUpIcon
        case "ArrowheadUpOutlineIcon": self = .arrowheadUpOutlineIcon
        case "ArrowCircleUpOutlineIcon": self = .arrowUpIcon
        case "ArrowUpCircleIcon": self = .arrowUpCircleIcon
        case "ArrowUpCircleFillIcon": self = .arrowUpCircleFillIcon
        case "ArrowUpCircleLineIcon": self = .arrowUpCircleLineIcon
        case "IconChevronCircleUp": self = .iconChevronCircleUp
        case "ArrowUpFillIcon": self = .arrowUpFillIcon
        case "ArrowUpLineIcon": self = .arrowUpLineIcon
        case "ArrowUpOutlineIcon": self = .arrowUpOutlineIcon
        case "ArrowUpsFillIcon": self = .arrowUpsFillIcon
        case "ArrowUpsLineIcon": self = .arrowUpsLineIcon
        case "LinkIcon": self = .linkIcon
        case "LinksLineIcon": self = .linksLineIcon
        case "ShareLineIcon": self = .shareLineIcon
        case "UploadOutlineIcon": self = .uploadOutlineIcon
        default: self = .custom(name)
        }
    }
    
    var systemIconName: String? {
        switch self {
        case .arrowUpIcon: return "arrow.up"
        case .arrowheadUpOutlineIcon,
                .arrowCircleUpOutlineIcon,
                .arrowUpCircleIcon,
                .arrowUpCircleLineIcon: return "arrow.up.circle"
        case .arrowUpCircleFillIcon: return "arrow.up.circle.fill"
        case .iconChevronCircleUp: return "chevron.up.circle"
        case .arrowUpFillIcon, .arrowUpLineIcon: return "arrow.up"
        case .arrowUpOutlineIcon: return "triangle"
        case .arrowUpsFillIcon: return "triangle.fill"
        case .arrowUpsLineIcon: return "chevron.up"
        case .linkIcon, .linksLineIcon: return "link"
        case .shareLineIcon: return "paperplane"
        case .uploadOutlineIcon: return "arrow.up.to.line"
        case .custom: return nil
        }
    }
}

extension SRIcon {
    enum CodingKeys: String, CodingKey {
        case name
    }
}
