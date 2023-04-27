//
//  RegisterView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var service: AccountService
    
    @State var phone: String = ""
    @State var password: String = ""
    @State var password2: String = ""
    
    @State var checked = false
    
    @Binding var page: OnboardingView.Page
    
    var body: some View {
        VStack {
            OnboardingHeader()
            Spacer().frame(height: 34)
            VStack(spacing: 21.5){
                OnboardingInput(title: "设置登录帐号", inputText: $phone)
                OnboardingSecureInput(title: "设置登录密码", inputText: $password)
                OnboardingSecureInput(title: "登录密码", inputText: $password2)
            }
            Spacer().frame(height: 41.5)
            Button("立即注册"){
                    Task {
                        await service.register(phone: phone, password: password, password1: password2)
                    }
            }
            .buttonStyle(OnboardingButton())
            Spacer().frame(height: 22.5)
            HStack(spacing: 2) {
                Toggle(isOn: $checked, label: {})
                    .toggleStyle(OrangeCheckBoxStyle())
                    .frame(width: 20, height: 20)
                Spacer().frame(width: 5)
                Text("已阅读并同意")
                    .orangeText(size: 13, color: .c000000)
                Button{
                } label: {
                    Text("《用户协议》")
                        .orangeText(size: 13, color: .main)
                }
                Text("及")
                    .orangeText(size: 13, color: .c000000)
                Button{
                } label: {
                    Text("《隐私政策》")
                        .orangeText(size: 13, color: .main)
                }
            }
            Spacer().frame(height: 33)
            HStack {
                Text("已经有帐号？")
                    .orangeText(size: 15, color: .c000000)
                Button {
                    page = .login
                } label: {
                    Text("立即注册")
                        .orangeText(size: 15, color: .main)
                }

            }
            Spacer()
        }
        .padding(.horizontal, 35)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(page: .constant(.register))
            .environmentObject(AccountService())
    }
}
