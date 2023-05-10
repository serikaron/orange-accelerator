//
//  Version.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import Foundation

@MainActor
struct Version {
    let version: String
    
    static var hasUpdate: Bool {
        get async {
            do {
                guard let clienVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                    throw "版本不存在"
                }
                
                let serverVersion = try await Linkman.shared.getUpdate().version_str
                
                return serverVersion > clienVersion
            } catch {
                Box.sendError(error)
                return false
            }
        }
    }
    
    static var clientVersion: String {
        guard let clienVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "0.0.0"
        }
        return clienVersion
    }
}
