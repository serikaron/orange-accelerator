//
//  OnboardingHeader.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/15.
//

import SwiftUI

struct OnboardingHeader: View {
    var body: some View {
        VStack{
            Image("logo")
            Spacer().frame(height: 36)
            Text("橙子加速器")
                .font(.system(size: 30).bold())
            Spacer().frame(height: 14.5)
            Text("开启橙子加速器，立即实现真正的在线隐私")
                .font(.system(size: 15))
        }
    }
}

struct OnboardingInput: View {
    var title: String
    @Binding var inputText: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $inputText)
                .padding()
                .frame(height: 45)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.main, lineWidth: 1)
                )
        }
    }
}

struct OnboardingSecureInput: View {
    var title: String
    @Binding var inputText: String
    @State var show: Bool = false
    
    var body: some View {
        VStack {
            Text(title)
            .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ZStack {
                    Group {
                        if show {
                            TextField("", text: $inputText)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            SecureField("", text: $inputText)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                Button(action: {
                    show = !show
                }) {
                    Image(show ? "eye.slash" : "eye")
                }
            }
            .padding()
            .frame(height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.main, lineWidth: 1)
            )
        }    }
}

struct OnboardingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .font(.system(size: 16))
            .foregroundColor(.white)
            .background(Color.main)
            .cornerRadius(25)
    }
}

struct OnboardingHeader_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingHeader()
                .previewDisplayName("header")
            OnboardingInput(title: "登录帐号", inputText: .constant("abc"))
                .previewDisplayName("input")
            OnboardingSecureInput(title: "登录帐号", inputText: .constant("abc"))
                .previewDisplayName("secure")
            Button("登录") {}
                .previewDisplayName("Button")
                .buttonStyle(OnboardingButton())
        }
    }
}
