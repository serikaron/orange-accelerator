//
//  orange_acceleratorApp.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

@main
struct orange_acceleratorApp: App {
    init() {
        Linkman.shared.presentation = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
