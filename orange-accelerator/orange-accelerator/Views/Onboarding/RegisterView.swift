//
//  RegisterView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import SwiftUI

struct RegisterView: View {
    @State var phone: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            OnboardingHeader()
            Spacer().frame(height: 34)
            OnboardingInput(title: "设置登录帐号", inputText: $phone)
            Spacer().frame(height: 21.5)
            OnboardingSecureInput(title: "设置登录密码", inputText: $password)
        }
        .padding(.horizontal, 35)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
