//
//  Model.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import Foundation

@MainActor
class Model: ObservableObject {
    static let shared = Model()
    
    // Account
    @Published var isLoggedIn: Bool = false
    
    // overlay
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var errorViewAlpha: Double = 0
    var vanTimer: Timer?
    var cleanTimer: Timer?
    
    // network
    var standalone = false
    var token: String? = nil
}
