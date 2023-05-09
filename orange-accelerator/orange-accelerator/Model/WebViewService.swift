//
//  WebViewService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import Foundation

@MainActor
enum WebViewService {
    static var policyURL: String {
        get async {
            do {
                return try await Linkman.shared.getPolicy()
            } catch {
                Box.sendError(error)
                return ""
            }
        }
    }
    
    static var onlineServiceURL: String {
        get async {
            do {
                return try await Linkman.shared.getOnlineService()
            } catch {
                Box.sendError(error)
                return ""
            }
        }
    }
}
