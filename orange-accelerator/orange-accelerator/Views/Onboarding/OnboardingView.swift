//
//  OnboardingView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/26.
//

import SwiftUI

struct OnboardingView: View {
    enum Page {
        case login, register
    }
    
    @State private var page = Page.login
    
    var body: some View {
        switch page {
        case .login: LoginView(page: $page)
        case .register: RegisterView(page: $page)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
