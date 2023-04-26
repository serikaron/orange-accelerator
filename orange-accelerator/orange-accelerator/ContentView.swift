//
//  ContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            content
            LoadingView()
            ErrorView()
        }
    }
    
    private var content: some View {
        Group {
            if model.isLoggedIn {
                Text("Loggined")
            } else {
                LoginView()
                    .environmentObject(model)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Model())
            .previewDisplayName("MainContent")
    }
}


