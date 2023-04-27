//
//  TokenService.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import Foundation
import Combine

@MainActor
class TokenService: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    var cancelable: Cancellable?
    
    init() {
        Box.shared.tokenSubject
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .assign(to: &$isLoggedIn)
        
        cancelable = Box.shared.tokenSubject
            .dropFirst()
            .sink(receiveValue: { token in
                UserDefaults.token = token
            })
    }
}

extension UserDefaults {
    static var token: String? {
        get {
            UserDefaults.orange.string(forKey: "token")
        }
        set(token) {
            UserDefaults.orange.setValue(token, forKey: "token")
        }
    }
}
