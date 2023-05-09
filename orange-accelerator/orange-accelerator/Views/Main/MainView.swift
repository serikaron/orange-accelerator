//
//  MainView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI
import Combine

private let MENU_WIDTH: CGFloat = 275

struct MainView: View {
    @StateObject private var onboardingService = OnboardingService()
    
    @State private var showSideMenu = false
    @State private var showNodeList = false
    @State private var showMemberStore = false
    @State private var showResetPassword = false
    @State private var showPopup = false
    @State private var popupType = PopupViewType.member
    @State private var showWebView = false
    @State private var webViewInfo: WebViewInfo = ("", "")
    
    @State private var maskAlpha: Double = 0
    @State private var sideMenuOffset: CGFloat = -MENU_WIDTH
    
    private let hidePopupSubject = HidePopupSubject()
    private let showPopupSubject = ShowPopupSubject()
    
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: NodeListView(), isActive: $showNodeList) {
                    EmptyView()
                }
                NavigationLink(destination: MemberStoreView(), isActive: $showMemberStore) {
                    EmptyView()
                }
                NavigationLink(destination: ResetPasswordView(), isActive: $showResetPassword) {
                    EmptyView()
                }
                NavigationLink(destination: WebView(title: webViewInfo.title, url: webViewInfo.url), isActive: $showWebView) {
                    EmptyView()
                }
                MainContentView(showSideMenu: $showSideMenu,
                                showNodeList: $showNodeList,
                                showMemberStore: $showMemberStore,
                                showPopup: showPopupSubject)
                Color.black.opacity(maskAlpha)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showSideMenu = false
                    }
                PopupView(type: popupType, isShow: $showPopup, buttonClick: hidePopupSubject)
                    .ignoresSafeArea()
                GeometryReader { geometry in
                    Group {
                        Color.white
                            .ignoresSafeArea()
                        SideMenuView(
                            showMemberStore: $showMemberStore,
                            showResetPassword: $showResetPassword,
                            showWebView: $showWebView,
                            webViewInfo: $webViewInfo
                        )
                    }
                    .frame(width: MENU_WIDTH)
                    .offset(x: sideMenuOffset, y: 0)
                }
            }
        }
        .onChange(of: showSideMenu) { isShow in
            withAnimation {
                maskAlpha = isShow ? 0.5 : 0
                sideMenuOffset = isShow ? 0 : -MENU_WIDTH
            }
        }
        .onReceive(showPopupSubject) { type in
            showPopup = true
            popupType = type
        }
        .onReceive(hidePopupSubject) { popupType in
            print("onReceive \(popupType)")
            switch popupType {
            case .member:
                showMemberStore = true
            case .mode:
                break
            }
        }
        .environmentObject(onboardingService)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
