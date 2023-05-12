//
//  ContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tokenService = TokenService()
    @StateObject private var nav = NavigationService()
    
    @State private var showFirstTimePopup = false
    
    var body: some View {
        ZStack {
            content
            LoadingView()
            ErrorView()
        }
    }
    
    private var content: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: WebView(page: nav.webPage ?? .privacy),
                               isActive: showWebView) {
                    EmptyView()
                }
                
                if tokenService.isLoggedIn {
                    MainView()
                } else {
                    OnboardingView()
                }
                
//                if showFirstTimePopup {
//                    FirstTimeRestartView()
//                }
            }
        }
        .onAppear {
            showFirstTimePopup = !FirstTimeRestart.done
        }
        .environmentObject(nav)
    }
    
    private var showWebView: Binding<Bool> {
        Binding {
            nav.webPage != nil
        } set: { show in
            if !show {
                nav.webPage = nil
            }
        }

    }
}

fileprivate struct SomeView: View {
    @StateObject var s: OnboardingService = OnboardingService()
    var body: some View {
        ZStack {
            Color.green
            Button("logout") {
                s.logout()
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


