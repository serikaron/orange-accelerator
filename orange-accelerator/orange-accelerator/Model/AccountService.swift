//
//  Account.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/16.
//

import Foundation


class AccountService: ObservableObject {
    enum AccountError: Error {
        case emptyPhone
        case emptyPassword
        
        var message: String {
            switch self {
            case.emptyPhone: return "手机不能为空"
            case .emptyPassword: return "密码不能为空"
            }
        }
    }
    
    func login(phone: String, password: String) async {
        if (phone.isEmpty) {
            Box.sendError(AccountError.emptyPhone)
            return
        }
        
        if (password.isEmpty) {
            Box.sendError(AccountError.emptyPassword)
            return
        }
        
        Box.setLoading(true)
        do {
            let loginRsp = try await Linkman.shared.login(phone: phone, password: password)
            // TODO: set token
            // TODO: set login
        } catch {
            print("make login request failed: \(error)")
        }
        Box.setLoading(false)
    }
}






