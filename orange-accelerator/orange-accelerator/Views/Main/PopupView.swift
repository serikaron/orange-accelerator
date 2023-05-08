//
//  PopupView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/8.
//

import SwiftUI
import Combine

enum PopupViewType {
    case member, mode
}

typealias HidePopupSubject = PassthroughSubject<PopupViewType, Never>
typealias ShowPopupSubject = PassthroughSubject<PopupViewType, Never>

struct PopupView: View {
    let type: PopupViewType
    @Binding var isShow: Bool
    
    @State private var backgroundAlpha: Double = 0
    @State private var scaleX: CGFloat = 0
    @State private var scaleY: CGFloat = 0
    
    let buttonClick: HidePopupSubject
    
    var body: some View {
        ZStack {
            Color.black
//                .opacity(0.5)
                .opacity(backgroundAlpha)
            VStack(spacing: 0) {
                Text(type.title)
                    .orangeText(size: 17, color: .c000000)
                    .frame(height: 40)
                Color.hex("#EDEDED")
                    .frame(height: 1)
                Spacer().frame(height: 16.5)
                VStack(spacing: 13) {
                    ForEach(type.content, id: \.self) { content in
                        Text(content)
                            .orangeText(size: 15, color: .c000000)
                    }
                }
                Spacer()
                Button {
                    isShow = false
                    buttonClick.send(type)
                } label: {
                    Text(type.buttonTitle)
                        .orangeText(size: 15, color: .white)
                        .frame(width: 100, height: 38)
                        .background(Color.main)
                        .cornerRadius(19)
                }
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 7.5)
            .frame(width: 278, height: 218)
            .background(.white)
            .cornerRadius(10)
            .scaleEffect(x: scaleX, y: scaleY)
        }
        .onChange(of: isShow) { isShow in
            withAnimation {
                backgroundAlpha = isShow ? 0.5 : 0
            }
            if isShow {
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                    scaleX = 1
                    scaleY = 1
                }
            } else {
                withAnimation {
                    scaleX = 0
                    scaleY = 0
                }
            }
        }
    }
}

struct PopupView_Previews: PreviewProvider {
    struct WrapperView: View {
        @State private var type: PopupViewType = .member
        @State private var isShow = false
        
        var body: some View {
            ZStack {
                PopupView(
                    type: type,
                    isShow: $isShow,
                    buttonClick: PassthroughSubject<PopupViewType, Never>()
                )
                VStack {
                    Spacer()
                    Button(isShow ? "hide" : "show") {
                        isShow = !isShow
                        if type == .member {
                            type = .mode
                        } else {
                            type = .member
                        }
                    }
                    Spacer().frame(height: 100)
                }
                .background(Color.clear)
            }
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}

extension PopupViewType {
    var title: String {
        return "提醒"
    }
    
    var content: [String] {
        switch self {
        case .member:
            return ["        只有开通会员才能使用此功能， 现在开通会员立即解锁超多付费网路， 速度更快，连接更稳定。"]
        case .mode:
            return ["智能模式：只有部分网络会通过橙子 加速路代理访问；",
                    "全局模式：所有访问均通过橙子加速 器代理访问。"]
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .member: return "立即开通"
        case .mode: return "确定"
        }
    }
}
