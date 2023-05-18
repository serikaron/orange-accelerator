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
    @StateObject var accountService = AccountService()
    @EnvironmentObject var nav: NavigationService
    
    @State private var showSideMenu = false
    @State private var showPopup = false
    @State private var popupType = RemindType.member
    @State private var showWebView = false
    @State private var webViewInfo: WebViewInfo = ("", "")
    @State private var showVersionPopp = false
    
    @State private var maskAlpha: Double = 0
    @State private var sideMenuOffset: CGFloat = -MENU_WIDTH
    
    private let hidePopupSubject = HideRemindSubject()
    private let showPopupSubject = ShowRemindSubject()
    
    
    var body: some View {
        ZStack {
            NavigationLink(destination: NodeListView().environmentObject(accountService),
                           isActive: $nav.showNodeList) {
                EmptyView()
            }
            NavigationLink(destination: MemberStoreView(), isActive: $nav.showMemberStore) {
                EmptyView()
            }
            NavigationLink(destination: ResetPasswordView().environmentObject(accountService), isActive: $nav.showResetPassword) {
                EmptyView()
            }
            NavigationLink(destination: InviteView().environmentObject(accountService),
                           isActive: $nav.showInviteView) {
                EmptyView()
            }
            MainContentView(showSideMenu: $showSideMenu,
                            showPopup: showPopupSubject)
            Color.black.opacity(maskAlpha)
                .ignoresSafeArea()
                .onTapGesture {
                    showSideMenu = false
                }
            RemindPopupView(type: popupType, isShow: $showPopup, buttonClick: hidePopupSubject)
                .ignoresSafeArea()
            GeometryReader { geometry in
                Group {
                    Color.white
                        .ignoresSafeArea()
                    SideMenuView(
                        showVersionPopup: $showVersionPopp
                    )
                }
                .frame(width: MENU_WIDTH)
                .offset(x: sideMenuOffset, y: 0)
            }
            VersionPopupView(isShow: $showVersionPopp)
                .ignoresSafeArea()
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
                nav.showMemberStore = true
            case .mode:
                break
            }
        }
        .environmentObject(onboardingService)
        .environmentObject(accountService)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(NavigationService())
    }
}
