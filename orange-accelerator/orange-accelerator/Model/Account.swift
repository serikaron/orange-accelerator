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
}

@MainActor
class AccountService: ObservableObject {
    @Published var account: Account?
    
    func loadAccount() async {
        do {
            let userInfo = try await Linkman.shared.getUserInfo()
            account = Account(id: userInfo.id, username: userInfo.username, isVip: userInfo.is_vip, vipExpiration: userInfo.expire_time, uuid: userInfo.uuid)
        } catch {
            Box.sendError(error)
        }
    }
    
    func resetPassword(oldPassword: String, newPassword: String) async {
        do {
            try await Linkman.shared.userRecover(oldPassword: oldPassword, newPassword: newPassword)
        } catch {
            Box.sendError(error)
        }
    }
}
