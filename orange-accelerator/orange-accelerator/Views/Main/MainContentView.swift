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
    @Binding var showSideMenu: Bool
    @Binding var showNodeList: Bool
    
    let showPopup: ShowPopupSubject
    
    @State private var routeMode = RouteMode.mode
    @State private var account: Account?
    
    @State private var connectionStatus: NEVPNStatus = .invalid
    
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
                Button {
                    connect()
                } label: {
                    Image("button.main.connected")
                        .padding(.top, 20)
                }
                Spacer().frame(height: 45)
                ConnectionStatusView(status: $connectionStatus)
            }
            Spacer()
            Button {
            } label: {
                HStack {
                    Image("button.member")
                    VStack(alignment: .leading) {
                        Text("开通会员")
                            .orangeText(size: 18, color: .white, weight: .bold)
                        Text("立即解锁高速连接")
                            .orangeText(size: 15, color: .white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
                .padding(.horizontal)
                .frame(height: 82)
                .frame(maxWidth: .infinity)
                .background(Color.main)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            Task {
                await NETunnelProviderManager.requestPermission()
                do {
                    account = try await Account.current
                } catch {
                    Box.sendError(error)
                }
            }
        }
        .onChange(of: routeMode) { newValue in
            RouteMode.mode = newValue
            if newValue == .intellegent {
                showPopup.send(.mode)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NEVPNStatusDidChange)) {
            guard let connection = $0.object as? NETunnelProviderSession else { return }
            if (connectionStatus != connection.status) {
                connectionStatus = connection.status
            }
        }
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
                if account?.isVip ?? false {
                    showNodeList = true
                } else {
                    showPopup.send(.member)
                }
            } label: {
                Text("更换")
                    .orangeText(size: 15, color: .main)
            }
        }
    }
    
    @MainActor
    private func connect() {
        Task {
            do {
                print("connect vpn")
                guard let account = account else {
                    throw "INVALID account !!!"
                }
                
                try await EndpointList.all
                    .filtered(isVip: account.isVip)
                    .ping()
                    .fastest()?
                    .connect(uuid: account.uuid, routeMode: routeMode)
            } catch {
                Box.sendError(error)
            }
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(showSideMenu: .constant(false), showNodeList: .constant(false), showPopup: ShowPopupSubject())
    }
}
