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
    
    // network
    var standalone = false
    var token: String? = nil
}
