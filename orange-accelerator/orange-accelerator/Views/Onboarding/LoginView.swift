//
//  LoginView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/15.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var service: OnboardingService
    
    @State var phone: String = ""
    @State var password: String = ""
    
    @Binding var page: OnboardingView.Page
    
    var body: some View {
        VStack {
            OnboardingHeader()
            Spacer().frame(height: 75)
            Group {
                OnboardingInput(title: "登录帐号", inputText: $phone)
                Spacer().frame(height: 35)
                OnboardingSecureInput(title: "登录密码", inputText: $password)
            }
            Spacer().frame(height: 44)
            Button("登录"){
                    Task {
                        await service.login(phone: phone, password: password)
                    }
            }
            .buttonStyle(OrangeButton())
            Spacer().frame(height: 27)
            HStack {
                Text("还没有帐号？")
                    .orangeText(size: 15, color: .c000000)
                Button {
                    page = .register
                } label: {
                    Text("立即注册")
                        .orangeText(size: 15, color: .main)
                }

            }
            Spacer()
        }
        .background(Color.white)
        .onTapGesture {
            hideKeyboard()
        }
        .padding(.horizontal, 35)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(page: .constant(.login))
    }
}
