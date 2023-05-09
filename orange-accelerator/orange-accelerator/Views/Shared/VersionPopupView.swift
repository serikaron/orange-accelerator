//
//  VersionPopupView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/10.
//

import SwiftUI

fileprivate let ANIMATION_DURATION = 0.2
fileprivate let OFFSET_Y: Double = -25

struct VersionPopupView: View {
    @Binding var isShow: Bool
    
    @State private var bgAlpha: Double = 0
    @State private var popupAlpha: Double = 0
    @State private var offsetY: Double = 0
    
    @State private var hideAll = true
    
    var body: some View {
        Group {
            if !hideAll {
                ZStack {
                    Color.black.opacity(bgAlpha)
                    popup
                        .opacity(popupAlpha)
                        .offset(y: offsetY)
                }
            }
        }
        .onChange(of: isShow) { isShow in
            if isShow {
                hideAll = false
                offsetY = OFFSET_Y
                withAnimation(.easeOut(duration: ANIMATION_DURATION)) {
                    bgAlpha = 0.5
                    popupAlpha = 1
                    offsetY = 0
                }
            } else {
                Task {
                    await animation(duration: ANIMATION_DURATION) {
                        bgAlpha = 0
                        popupAlpha = 0
                        offsetY = OFFSET_Y
                    }
                    hideAll = true
                }
            }
        }
    }
    
    private var popup: some View {
        Image("version.popup.bg")
            .overlay {
                VStack(spacing: 37) {
                    Spacer()
                    Text("发现新版本")
                        .orangeText(size: 25, color: .c000000)
                    Button("立即升级") {isShow = false}
                        .buttonStyle(OrangeButton())
                }
                .padding(32)
            }
    }
}

fileprivate struct WrapView: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            VersionPopupView(isShow: $show)
            VStack {
                Spacer()
                Button {
                    show.toggle()
                } label: {
                    Text(show ? "hide" : "show")
                }
            }
        }
    }
}

struct VersionPopupView_Previews: PreviewProvider {
    static var previews: some View {
        WrapView()
    }
}
