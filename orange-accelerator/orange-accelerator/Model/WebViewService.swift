//
//  WebViewService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import Foundation

@MainActor
enum WebViewPage {
    case privacy, customService, inviteRule
    
    var title: String {
        switch self {
        case .privacy: return "隐私政策"
        case .customService: return "在线客服"
        case .inviteRule: return "活动细则"
        }
    }
    
    var url: String? {
        get async throws {
            switch self {
            case .privacy: return nil
            case .customService: return try await Linkman.shared.getOnlineService()
            case .inviteRule: return nil
            }
        }
    }
    
    var htmlContent: String? {
        get async throws {
            switch self {
            case .privacy: return try await Linkman.shared.getPolicy()
            case .customService: return nil
            case .inviteRule: return try await Linkman.shared.getInviteRule()
            }
        }
    }
}


