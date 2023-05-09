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
//        NavigationView {
//            NavigationLink(destination: WebView(request: "https://www.baidu.com")) {
//                Text("baidu")
//            }
//        }
    }
    
    private var content: some View {
        Group {
            if tokenService.isLoggedIn {
                MainView()
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


