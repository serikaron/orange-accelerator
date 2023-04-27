//
//  OnboardingView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var service = AccountService()
    
    enum Page {
        case login, register
    }
    
    @State private var page = Page.login
    
    var body: some View {
        Group {
            switch page {
            case .login: LoginView(page: $page)
            case .register: RegisterView(page: $page)
            }
        }
        .environmentObject(service)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
