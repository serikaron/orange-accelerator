//
//  MainContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI

struct MainContentView: View {
    @StateObject private var v2Service = V2Service()
    
    @Binding var showSideMenu: Bool
    
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
                ModePickerView()
                    .padding(.horizontal)
            Spacer().frame(height: 45)
            statusButton
                Image("button.main.connected")
                    .padding(.top, 20)
            Spacer().frame(height: 45)
                HStack {
                    Text("链接状态：")
                        .orangeText(size: 15, color: .c000000)
                    Text("已连接")
                        .orangeText(size: 15, color: .hex("#02C91E"))
                }
            Spacer().frame(height: 45)
                Text("02：26：17")
                    .orangeText(size: 15, color: .c000000)
                    .padding(.top, -20)
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
        .environmentObject(v2Service)
        .onAppear {
            Task {
                await v2Service.loadConfig()
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
            Text("更换")
                .orangeText(size: 15, color: .main)
        }
    }
    
    var statusButton: some View {
        Button {
            Task {
                switch v2Service.state {
                case .initial: await v2Service.inatallProfile()
                case .installed: await v2Service.enable()
                case .enabled: v2Service.sayHelloToTunnel()
                case .ready: v2Service.start()
                }
            }
        } label: {
            switch v2Service.state {
            case .initial: Text("install")
            case .installed: Text("enable")
            case .enabled: Text("say hello")
            case .ready: Text("connect")
            }
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView(showSideMenu: .constant(false))
    }
}
