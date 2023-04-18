//
//  Account.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/16.
//

import Foundation

@MainActor
class Account: ObservableObject {
    @Published var isLogged: Bool = false
    @Published var error: Error? = nil
}


// MARK: - login

extension Account {
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
            guard let r = try await Request(
                path: "/login",
                method: .GET,
                body: LoginBody(phone: phone, password: password),
                mockResponse: LoginResponse(token: "mockToken")
            )
                .make()?
                .decode() as LoginResponse?
            else {
                error = LoginError.loginFailed
                return
            }
            
            Linkman.shared.token = r.token
            
            isLogged = true
            error = nil
        } catch {
            print("make login request failed: \(error)")
            self.error = LoginError.loginFailed
        }
    }
}

struct LoginBody: Encodable {
    let phone: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
}


