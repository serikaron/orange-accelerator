//
//  orange_acceleratorApp.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

@main
struct orange_acceleratorApp: App {
    @StateObject var model = Model.shared
        .withStandalone()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}

extension Model {
    func withStandalone() -> Model {
        self.standalone = true
        return self
    }
}
