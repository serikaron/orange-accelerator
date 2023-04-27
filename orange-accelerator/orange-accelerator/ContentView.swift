//
//  ContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tokenService = TokenService()
    
    var body: some View {
        ZStack {
            content
            LoadingView()
            ErrorView()
        }
    }
    
    private var content: some View {
        Group {
            if tokenService.isLoggedIn {
                Button {
                    Box.setToken(nil)
                } label: {
                    Text("Logout")
                }
            } else {
                OnboardingView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDisplayName("MainContent")
    }
}


