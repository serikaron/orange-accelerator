//
//  LoginView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/15.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var model: Model
    @State var phone: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            OnboardingHeader()
            Spacer().frame(height: 75)
            OnboardingInput(title: "登录帐号", inputText: $phone)
            Spacer().frame(height: 35)
            OnboardingSecureInput(title: "登录密码", inputText: $password)
            Spacer().frame(height: 44)
            Button("登录"){
                    Task {
                        await model.login(phone: phone, password: password)
                    }
            }
            .buttonStyle(OnboardingButton())
            Spacer().frame(height: 27)
            HStack {
                Text("还没有帐号？")
                    .font(.system(size: 15))
                Button {
                } label: {
                    Text("立即注册")
                        .font(.system(size: 15))
                        .foregroundColor(.main)
                }

            }
            Spacer()
        }
//        .background(Color.blue)
        .padding(.top, 65)
        .padding(.horizontal, 35)
    }
}

fileprivate extension Text {
    static func contentText(_ text: String) -> Text {
        return Text(text)
            .font(.system(size: 15))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
