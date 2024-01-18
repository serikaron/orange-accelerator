//
//  MainContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI
import V2orange
import NetworkExtension

struct MainContentView: View {
    @EnvironmentObject var nav: NavigationService
    @EnvironmentObject var accountService: AccountService
    @StateObject var conn = ConnectionService()
    
    @Binding var showSideMenu: Bool
    
    let showPopup: ShowRemindSubject
    
    @State private var routeMode = RouteMode.mode
    
    var body: some View {
        VStack(spacing: 0) {
            title
            Color(hex: "#EDEDED")
                .frame(height: 1)
            Spacer().frame(height: 45)
            Group {
                nodeSection
                    .pickerStyle(.segmented)
                Spacer().frame(height: 45)
                ModePickerView(routeMode: $routeMode)
                    .padding(.horizontal)
                Spacer().frame(height: 45)
                ConnectButton()
                Spacer().frame(height: 45)
                ConnectionStatusView()
            }
            Spacer()
//            Button {
//                nav.showMemberStore = true
//            } label: {
//                HStack {
//                    Image("button.member")
//                    VStack(alignment: .leading) {
//                        Text("开通会员")
//                            .orangeText(size: 18, color: .white, weight: .bold)
//                        Text("立即解锁高速连接")
//                            .orangeText(size: 15, color: .white)
//                    }
//                    Spacer()
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(.white)
//                        .padding(.trailing)
//                }
//                .padding(.horizontal)
//                .frame(height: 82)
//                .frame(maxWidth: .infinity)
//                .background(Color.main)
//                .cornerRadius(10)
//                .padding(.horizontal)
//                .padding(.bottom, 40)
//            }
            Button {
                Task {
                    await conn.refresh()
                }
            } label: {
                Text("更新")
                    .frame(width: 200, height: 50)
                    .foregroundColor(Color.main)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.main, lineWidth: 1)
                    )
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            Task {
                await NETunnelProviderManager.requestPermission()
                await accountService.loadAccount()
            }
        }
        .onChange(of: routeMode) { newValue in
            RouteMode.mode = newValue
            if newValue == .intellegent {
                showPopup.send(.mode)
            }
        }
        .onReceive(conn.$status, perform: { newStatus in
            switch (conn.status, newStatus) {
            case (.connected, .disconnected):
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case (.connecting, .connected):
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            default: break
            }
        })
        .environmentObject(conn)
        .environmentObject(accountService)
    }
    
    var title: some View {
        ZStack {
            HStack {
                Button {
                    showSideMenu = true
                } label: {
                    Image("main.menu")
                }
                Spacer()
            }
            Text("橙子加速器")
                .orangeText(size: 16, color: .c000000)
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
    
    var nodeSection: some View {
        HStack {
            Image("main.ball")
            Spacer().frame(width: 12)
            VStack(alignment: .leading) {
                Text("自动匹配最快网路")
                    .orangeText(size: 16, color: .c000000)
                Text("随时随刻为您选择当前最快网路连接")
                    .orangeText(size: 12, color: .hex("#999999"))
            }
            Spacer().frame(width: 15)
            Button {
                print("clicked 更换")
                if accountService.account?.isVip ?? false {
                    nav.showNodeList = true
                } else {
                    showPopup.send(.member)
                }
            } label: {
                Text("更换")
                    .orangeText(size: 15, color: .main)
            }
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(showSideMenu: .constant(false),
                        showPopup: ShowRemindSubject())
        .environmentObject(NavigationService())
        .environmentObject(AccountService())
    }
}
