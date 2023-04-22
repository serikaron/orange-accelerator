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
    }
    
    func login(phone: String, password: String) async {
        if (phone.isEmpty) {
            error = LoginError.invalidPhone
            return
        }
        
        if (password.isEmpty) {
            error = LoginError.invalidPassword
            return
        }
        
        do {
            let loginRsp = try await makeLogin(phone: phone, password: password)
            token = loginRsp.token
            isLogged = true
            error = nil
        } catch {
            print("make login request failed: \(error)")
            self.error = LoginError.loginFailed
        }
    }
}






