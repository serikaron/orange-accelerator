//
//  ResetPasswordView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var account: Account?
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var newPassword1 = ""
    
    var body: some View {
        VStack {
            header
            Spacer().frame(height: 73)
            VStack(spacing: 21.5){
                OnboardingSecureInput(title: "输入原密码", inputText: $oldPassword)
                OnboardingSecureInput(title: "设置新密码", inputText: $newPassword)
                OnboardingSecureInput(title: "重复新密码", inputText: $newPassword1)
            }
            Spacer().frame(height: 41.5)
            Button("立即修改"){
                resetPassword()
            }
            .buttonStyle(OrangeButton())
            Spacer().frame(height: 33)
            HStack(spacing: 0) {
                Text("如果忘记密码，请联系")
                    .orangeText(size: 15, color: .c000000)
                Button {
                } label: {
                    Text("在线客服")
                        .orangeText(size: 15, color: .main)
                }

            }
            Spacer()
        }
        .padding(.horizontal, 35)
        .onAppear {
            Task {
                do {
                    account = try await Account.current
                } catch {
                    Box.sendError(error)
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 14) {
            Image("logo")
            Text("用户名：  \(account?.username ?? "")")
        }
    }
    
    @MainActor
    private func resetPassword() {
        Task {
            do {
                if oldPassword == "" {
                    throw "请输入旧密码"
                }
                
                if newPassword == "" {
                    throw "请输入新密码"
                }
                
                if newPassword != newPassword1 {
                    throw "两次密码输入不一样"
                }
                
                await Account.resetPassword(oldPassword: oldPassword, newPassword: newPassword)
            } catch {
                Box.sendError(error)
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
