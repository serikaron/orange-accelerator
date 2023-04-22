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
    @Published var isLogged: Bool = false
    @Published var error: Error? = nil
    
    // network
    var standalone = false
    var token: String? = nil
}
