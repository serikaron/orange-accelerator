//
//  SideMenuView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var onboardingService: OnboardingService
    
    var body: some View {
        VStack {
            info
            Spacer().frame(height: 35)
            list
            Spacer()
            Button("退出登录") {
                onboardingService.logout()
            }
                .buttonStyle(OrangeButton())
                .padding(.horizontal, 20)
            Spacer().frame(height: 15.5)
            HStack(spacing: 0) {
                Text("当前版本：")
                    .orangeText(size: 12, color: .c999999)
                Text("V2.1.13")
                    .orangeText(size: 12, color: .c999999)
            }
        }
        .background(Color.white)
//        .padding(.top, 20.5)
        .padding(.bottom, 37.5)
//        .ignoresSafeArea()
    }
    
    private var info: some View {
        VStack {
            Image("logo")
            Spacer().frame(height: 20)
            HStack(spacing: 0) {
                Text("用户名：")
                    .orangeText(size: 16, color: .c999999)
                Text("Whitney001")
                    .orangeText(size: 16, color: .c999999)
            }
            Spacer().frame(height: 12)
            HStack(spacing: 0) {
                Text("到期时间：")
                    .orangeText(size: 12, color: .c999999)
                Text("2023-05-30")
                    .orangeText(size: 12, color: .c999999)
            }
        }
    }
    
    private var list: some View {
        VStack {
            Color(hex: "#EDEDED").frame(height: 1)
            ForEach(MenuItem.allCases) { item in
                MenuItemView(item: item)
                Color(hex: "#EDEDED").frame(height: 1)
            }
        }
    }
}

fileprivate struct MenuItemView: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 15) {
            Image(item.icon)
            Text(item.title)
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }
}

fileprivate enum MenuItem: CaseIterable, Identifiable {
    case member,password,customService,privacy,version
    
    var id: String { icon }
    
    var icon: String {
        switch self {
        case .member: return "menu.member"
        case .password: return "menu.password"
        case .customService: return "menu.custom.service"
        case .privacy: return "menu.privacy"
        case .version: return "menu.version"
        }
    }
    
    var title: String {
        switch self {
        case .member: return "续费会员"
        case .password: return "修改密码"
        case .customService: return "在线客服"
        case .privacy: return "隐私政策"
        case .version: return "检查更新"
        }
    }
}


struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView()
            .environmentObject(OnboardingService())
    }
}
