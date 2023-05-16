//
//  Account.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation
import UIKit

struct Account {
    let id: Int
    let username: String
    let isVip: Bool
    let vipExpiration: Int
    let uuid: String
    let invitationCode: String
    
    var invitationLink: String {
        var c = URLComponents.orange()
        c.path = "/" + invitationCode
        return c.url?.absoluteString ?? ""
    }
}

@MainActor
class AccountService: ObservableObject {
    @Published var account: Account?
    
    func loadAccount() async {
        do {
            let userInfo = try await Linkman.shared.getUserInfo()
            account = Account(
                id: userInfo.id,
                username: userInfo.username,
                isVip: userInfo.is_vip,
                vipExpiration: userInfo.expire_time,
                uuid: userInfo.uuid,
                invitationCode: userInfo.invitation_code
            )
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
    
    func copyCode() {
        UIPasteboard.general.string = account?.invitationCode ?? ""
    }
    
    func copyLink() {
        UIPasteboard.general.string = account?.invitationLink ?? ""
    }
}

extension Account {
    static var standalone: Account {
        Account(
            id: 1,
            username: "serika",
            isVip: false,
            vipExpiration: 0,
            uuid: "073c3ae5-4868-3da4-8d8d-ff1e29ed974f",
            invitationCode: "00552082"
        )
    }
}
