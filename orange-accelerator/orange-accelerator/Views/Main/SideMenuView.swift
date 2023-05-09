//
//  SideMenuView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI
import Combine

fileprivate typealias ItemTapped = PassthroughSubject<MenuItem, Never>

struct SideMenuView: View {
    @EnvironmentObject var onboardingService: OnboardingService
    @Binding var showMemberStore: Bool
    @Binding var showResetPassword: Bool
    @Binding var showWebView: Bool
    @Binding var webViewInfo: WebViewInfo
    
    @State private var account: Account?
    
    private let itemTapped = ItemTapped()
    
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
        .padding(.bottom, 37.5)
        .onReceive(itemTapped) { item in
            switch item {
            case .member:
                showMemberStore = true
                break
            case .password:
                showResetPassword = true
                break
            case .customService:
                Task {
                    webViewInfo = (title: "在线客服", url: await WebViewService.onlineServiceURL)
                    showWebView = true
                }
            case .privacy:
                Task {
                    webViewInfo = (title: "隐私政策", url: await WebViewService.policyURL)
                    showWebView = true
                }
            default:
                break
            }
        }
        .onAppear {
            Task {
                do {
                    account = try await Account.current
                } catch {
                    Box.sendError(error)
                }
            }
        }
    }
    
    private var info: some View {
        VStack {
            Image("logo")
            Spacer().frame(height: 20)
            HStack(spacing: 0) {
                Text("用户名：")
                    .orangeText(size: 16, color: .c999999)
                Text(account?.username ?? "")
                    .orangeText(size: 16, color: .c999999)
            }
            Spacer().frame(height: 12)
            HStack(spacing: 0) {
                Text("到期时间：")
                    .orangeText(size: 12, color: .c999999)
                Text(expiration)
                    .orangeText(size: 12, color: .c999999)
            }
        }
    }
    
    private var list: some View {
        VStack {
            Color(hex: "#EDEDED").frame(height: 1)
            ForEach(MenuItem.allCases) { item in
                MenuItemView(item: item, itemTapped: itemTapped)
                Color(hex: "#EDEDED").frame(height: 1)
            }
        }
    }
    
    private var expiration: String {
        guard let expiration = account?.vipExpiration else {
            return ""
        }
        guard account?.isVip ?? false else {
            return ""
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(expiration))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "HKT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}

fileprivate struct MenuItemView: View {
    let item: MenuItem
    
    let itemTapped: ItemTapped
    
    var body: some View {
        Button {
            itemTapped.send(item)
        } label: {
            HStack(spacing: 15) {
                Image(item.icon)
                Text(item.title)
                    .orangeText(size: 15, color: .c000000)
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
        }
//        .onTapGesture { itemTapped.send(item) }
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
        SideMenuView(
            showMemberStore: .constant(false),
            showResetPassword: .constant(false),
            showWebView: .constant(false),
            webViewInfo: .constant(("", ""))
        )
            .environmentObject(OnboardingService())
    }
}
