//
//  Account.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation

struct Account {
    let id: Int
    let username: String
    let isVip: Bool
    let vipExpiration: Int
    let uuid: String
    
    private static var _account: Account?
    
    static var current: Account {
        get async throws {
            if let account = _account { return account }
            
            let account = try await Linkman.shared.getUserInfo()
            _account = Account(id: account.id, username: account.username, isVip: account.is_vip, vipExpiration: account.expire_time, uuid: account.uuid)
            return _account!
        }
    }
    
    @MainActor
    static func resetPassword(oldPassword: String, newPassword: String) async {
        do {
            try await Linkman.shared.userRecover(oldPassword: oldPassword, newPassword: newPassword)
        } catch {
            Box.sendError(error)
        }
    }
    
    static func clean() {
        _account = nil
    }
}


