//
//  Account.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/16.
//

import Foundation


// MARK: - login
extension Model {
    enum LoginError: Error {
        case invalidPhone
        case invalidPassword
        case loginFailed
        
        var message: String {
            switch self {
            case .invalidPhone: return "phone"
            case .invalidPassword: return "password"
            case .loginFailed: return "loginFailed"
            }
        }
    }
    
    func login(phone: String, password: String) async {
        if (phone.isEmpty) {
            errorMessage = LoginError.invalidPhone.message
            return
        }
        
        if (password.isEmpty) {
            errorMessage = LoginError.invalidPassword.message
            return
        }
        
        isLoading = true
        do {
            let loginRsp = try await makeLogin(phone: phone, password: password)
            token = loginRsp.token
            isLoggedIn = true
            errorMessage = nil
        } catch {
            print("make login request failed: \(error)")
            self.errorMessage = LoginError.loginFailed.message
        }
        isLoading = false
    }
}






