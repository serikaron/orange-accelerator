//
//  PopupView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/8.
//

import SwiftUI
import Combine

// MARK: -- popup base

fileprivate let ANIMATION_DURATION = 0.2
fileprivate let OFFSET_Y: Double = -25

fileprivate struct PopupWrapper<Content>: View where Content: View {
    @Binding var isShow: Bool
    
    let popup: () -> Content
    
    @State private var hideAll = true
    
    @State private var backgroundAlpha: Double = 0
    @State private var popupAlpha: Double = 0
    @State private var offsetY: Double = 0
    
    
    var body: some View {
        Group {
            if !hideAll {
                ZStack {
                    Color.black
                        .opacity(backgroundAlpha)
                    popup()
                        .offset(y: offsetY)
                        .opacity(popupAlpha)
                }
            }
        }
        .onChange(of: isShow) { isShow in
            if isShow {
                hideAll = false
                offsetY = OFFSET_Y
                withAnimation(.linear(duration: ANIMATION_DURATION)) {
                    backgroundAlpha = 0.5
                    popupAlpha = 1
                    offsetY = 0
                }
            } else {
                Task {
                    await animation(duration: ANIMATION_DURATION) {
                        backgroundAlpha = 0
                        popupAlpha = 0
                        offsetY = OFFSET_Y
                    }
                    hideAll = true
                }
            }
        }
    }
}

// MARK: -- RemindPopup

enum RemindType {
    case member, mode
}

typealias HideRemindSubject = PassthroughSubject<RemindType, Never>
typealias ShowRemindSubject = PassthroughSubject<RemindType, Never>

struct RemindPopupView: View {
    let type: RemindType
    
    @Binding var isShow: Bool
    let buttonClick: HideRemindSubject
    
    
    var body: some View {
        PopupWrapper(isShow: $isShow) {
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
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}

extension RemindType {
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

// MARK: -- VersionPopup

struct VersionPopupView: View {
    @Binding var isShow: Bool
    
    var body: some View {
        PopupWrapper(isShow: $isShow) {
            Image("version.popup.bg")
                .overlay (
                    VStack() {
                        Spacer()
                        Text("发现新版本")
                            .orangeText(size: 25, color: .c000000)
                        Spacer().frame(height: 37)
                        Button("立即升级") {
                            isShow = false
                        }
                        .buttonStyle(OrangeButton())
                    }.padding(32)
                )
        }
    }
}

// MARK: -- FirstTimeRestartView

struct FirstTimeRestartView: View {
//    @Binding var isShow: Bool
    
    private enum ViewState {
        case initial, updating, done
    }
    @State private var state = ViewState.initial
    @State private var progress: Double = 0
    
    var body: some View {
//        PopupWrapper(isShow: $isShow) {
        ZStack {
            Color.black.opacity(0.5)
            Image("version.popup.bg")
                .overlay (
                    VStack() {
                        Spacer()
                        switch state {
                        case .initial: initialView
                        case .updating: updateingView
                        case .done: doneView
                        }
                    }.padding(32)
                )
        }
//        }
    }
    
    private var initialView: some View {
        VStack {
            Text("发现新版本")
                .orangeText(size: 25, color: .c000000)
            Spacer().frame(height: 37)
            Button("立即升级") {
                Task {
                    state = .updating
                }
            }
            .buttonStyle(OrangeButton())
        }
    }
    
    private var updateingView: some View {
        VStack {
            ProgressView(value: progress)
            Spacer().frame(height: 12.5)
            Text("\(Int(progress*100))%").orangeText(size: 15, color: .c000000)
            Spacer().frame(height: 24)
            Spacer().frame(height: 50)
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            progress += 0.03
            if progress >= 1 {
                state = .done
            }
        }
    }
    
    private var doneView: some View {
        VStack {
            ProgressView(value: 1)
            Spacer().frame(height: 12.5)
            Text("100%").orangeText(size: 15, color: .c000000)
            Spacer().frame(height: 24)
            Button("立即重启") {
                FirstTimeRestart.done = true
                exit(0)
            }
            .buttonStyle(OrangeButton())
        }
    }
}

struct PopupView_Previews: PreviewProvider {
    struct WrapperView<Content: View>: View {
        let content: (Binding<Bool>) -> Content
        
        @State private var isShow = false
        
        var body: some View {
            ZStack {
                content($isShow)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Button("toggle") {
                        isShow.toggle()
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        WrapperView { isShow in
            Button("hide") {
                isShow.wrappedValue = false
            }
        }
        .previewDisplayName("Popup")
        
        WrapperView { isShow in
            RemindPopupView(
                type: .member,
                isShow: isShow,
                buttonClick: HideRemindSubject()
            )
        }
        .previewDisplayName("RemindPopup-member")
        WrapperView { isShow in
            RemindPopupView(
                type: .mode,
                isShow: isShow,
                buttonClick: HideRemindSubject())
        }
        .previewDisplayName("RemindPopup-mode")
        
        WrapperView { isShow in
            VersionPopupView(isShow: isShow)
        }
        .previewDisplayName("VersionPopup")
        
        WrapperView { isShow in
            FirstTimeRestartView()
        }
        .previewDisplayName("firstTimeRestart")
    }
}

