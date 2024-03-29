//
//  Account.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/16.
//

import Foundation


@MainActor
class OnboardingService: ObservableObject {
    enum OnboardingError: Error {
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
            Box.sendError(OnboardingError.emptyPhone)
            return
        }
        
        if (password.isEmpty) {
            Box.sendError(OnboardingError.emptyPassword)
            return
        }
        
        Box.setLoading(true)
        do {
            let loginRsp = try await Linkman.shared.login(phone: phone, password: password)
            Box.setToken(loginRsp.access_token)
        } catch {
            print("make login request failed: \(error)")
        }
        Box.setLoading(false)
    }
    
    func register(phone: String, password: String, inviteCode: String?) async {
        if (phone.isEmpty) {
            Box.sendError(OnboardingError.emptyPhone)
            return
        }
        
        if (password.isEmpty) {
            Box.sendError(OnboardingError.emptyPassword)
            return
        }

        Box.setLoading(true)
        do {
            let registerRsp = try await Linkman.shared.register(phone: phone, password: password, inviteCode: inviteCode)
            Box.setToken(registerRsp.access_token)
        } catch {
            print("make register request failed: \(error)")
        }
        Box.setLoading(false)
    }
    
    func logout() {
        Box.setToken(nil)
    }
}






