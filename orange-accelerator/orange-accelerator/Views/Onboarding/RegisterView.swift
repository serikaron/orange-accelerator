//
//  RegisterView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var service: OnboardingService
    @EnvironmentObject var nav: NavigationService
    
    @State var phone: String = ""
    @State var password: String = ""
    @State var password1: String = ""
    @State var inviteCode: String = ""
    
    @State var checked = false
    
    @Binding var page: OnboardingView.Page
    
    var body: some View {
        VStack {
            OnboardingHeader()
            Spacer().frame(height: 34)
            VStack(spacing: 21.5){
                OnboardingInput(title: "设置登录帐号", inputText: $phone)
                OnboardingSecureInput(title: "设置登录密码", inputText: $password)
                OnboardingSecureInput(title: "登录密码", inputText: $password1)
                OnboardingInput(title: "邀请码", inputText: $inviteCode)
            }
            Spacer().frame(height: 41.5)
            Button("立即注册"){
                register()
            }
            .buttonStyle(OrangeButton())
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
                    nav.webPage = .privacy
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
                    Text("立即登录")
                        .orangeText(size: 15, color: .main)
                }
                
            }
            Spacer()
        }
        .padding(.horizontal, 35)
        .background(Color.white)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func register() {
        Task {
            if (password != password1) {
                Box.sendError("两次密码输入不一样")
                return
            }
            
            if !checked {
                Box.sendError("请阅读并同意《用户协议》和《隐私政策》")
                return
            }
            
            await service.register(phone: phone, password: password, inviteCode: inviteCode.isEmpty ? nil : inviteCode)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(page: .constant(.register))
            .environmentObject(OnboardingService())
    }
}
