//
//  InviteView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/15.
//

import SwiftUI

struct InviteView: View {
    @StateObject private var service = InviteService()
    @EnvironmentObject var accountService: AccountService
    
    @Environment(\.openURL) var openURL
    
    @State private var isShowMore = false
    private var itemList: SharedList {
        if isShowMore {
            return service.sharedList
        }
        
        let count = min(3, service.sharedList.count)
        return Array(service.sharedList[0..<count])
    }
    
    var body: some View {
        VStack {
            NavigationTitleView(title: "邀请好友")
                .overlay(detailButton, alignment: .trailing)
            content
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await service.loadSharedList(page: 1, perPage: 100)
                await service.loadPrizeDays()
            }
        }
    }
    
    var detailButton: some View {
        NavigationLink(destination: WebView(page: .inviteRule)) {
            Text("活动细则")
                .orangeText(size: 14, color: .c000000)
                .padding(.trailing, 15)
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            section1
            Separator()
            section2
            Separator()
            section3
            Separator()
            section4
        }
        .padding(.horizontal, 15)
    }
    
    var section1: some View {
        VStack {
            Text("邀请还有得\(service.days)天会员时长")
                .orangeText(size: 25, color: .c000000)
            Spacer().frame(height: 11)
            Text("每邀请1位好友下单，即可获得")
                .orangeText(size: 13, color: .c000000)
            Spacer().frame(height: 18)
            Image("invite.ticket")
        }
        .padding(.top, 26.5)
        .padding(.bottom, 22)
    }
    
    var section2: some View {
        func row(text1: String, text2: String, action: @escaping () -> Void) -> some View {
            HStack {
                Text(text1).orangeText(size: 15, color: .c000000)
                Text(text2).orangeText(size: 15, color: .main)
                    .lineLimit(1)
                //                    .frame(maxWidth: 163)
                    .truncationMode(.tail)
                Button {
                    action()
                } label: {
                    Image("icon.copy")
                }
            }
            .padding(.horizontal)
        }
        
        return VStack(spacing: 13.5) {
            row(text1: "邀请码：", text2: accountService.account?.invitationCode ?? "") {
                accountService.copyCode()
            }
            row(text1: "邀请链接：", text2: accountService.account?.invitationLink ?? "") {
                accountService.copyLink()
            }
        }
        .padding(.vertical, 20)
    }
    
    var section3: some View {
        VStack {
            Text("邀请攻略").orangeText(size: 15, color: .c000000)
            Spacer().frame(height: 15)
            VStack {
                HStack( spacing: 4.5) {
                    Text("1").stepLabel(line1: "发送邀请链接给", line2: "好友")
                    Color.main.frame(width: 97.5, height: 1)
                    Text("2").stepLabel(line1: "好友注册并", line2: "登录APP")
                    Color.main.frame(width: 97.5, height: 1)
                    Text("3").stepLabel(line1: "会员时长", line2: "到账")
                }
                Spacer()
            }.frame(height: 57)
            Spacer().frame(height: 29.5)
            Text("分享给好友").orangeText(size: 15, color: .c000000)
            Spacer().frame(height: 16)
            HStack {
                sharedButton(with: .wechat)
                Spacer()
                sharedButton(with: .qq)
                Spacer()
                sharedButton(with: .weibo)
            }.padding(.horizontal, 50)
        }
        .padding(.top, 23)
        .padding(.bottom, 24.5)
    }
    
    var section4: some View {
        VStack {
            Text("我的奖励记录")
                .orangeText(size: 15, color: .c000000)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4.5)
            Spacer().frame(height: 19)
            listItemView(name: "被推荐人", prize: "奖励", time: "获得时间", fontSize: 13)
            ScrollView {
                itemList.uiForEach { _, item in
                    listItemView(item: item)
                }
            }
            if !isShowMore {
                Spacer().frame(height: 24)
                Button {
                    isShowMore = true
                } label: {
                    Text("点击加载更多")
                        .orangeText(size: 13, color: .c000000)
                }
            }
        }
        .padding(.top, 22.5)
        .padding(.bottom, 10)
    }
    
    func listItemView(item: SharedItem) -> some View {
        listItemView(name: item.name, prize: item.prize, time: item.time, fontSize: 12)
    }
    
    func listItemView(name: String, prize: String, time: String, fontSize: CGFloat) -> some View {
        HStack {
            Text(name).orangeText(size: fontSize, color: .c000000)
                .frame(width: 100)
            Spacer()
            Text(prize).orangeText(size: fontSize, color: .c000000)
            Spacer()
            Text(time).orangeText(size: fontSize, color: .c000000)
                .frame(width: 100)
        }
        .frame(height: 25)
        .padding(.horizontal, 20)
    }
    
    func sharedButton(with destination: ShareDestination) -> some View {
        Button {
            accountService.copyLink()
            openURL(URL(string: destination.link)!) { success in
                if !success {
                    Box.sendError("跳转到\(destination.appName)失败")
                }
            }
        } label: {
            Image(destination.imageName)
        }
    }
}
    
extension Array {
    func zipWithIndices() -> [(Int, Self.Element)]{
        Array<(Int, Self.Element)>(zip(self.indices, self))
    }
    
    func uiForEach<Content: View>(_ itemView: @escaping (Int, Self.Element) -> Content) -> some View {
        ForEach(self.zipWithIndices(), id: \.0, content: itemView)
    }
}

fileprivate struct StepLabel: ViewModifier {
    let line1: String
    let line2: String
    
    func body(content: Content) -> some View {
        Color.clear
            .frame(width: 16, height: 16)
            .overlay(
                VStack(alignment: .center) {
                    content
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background( Circle() .fill(Color.main) )
                    Text(line1).orangeText(size: 13, color: .c000000)
                    Text(line2).orangeText(size: 13, color: .c000000)
                }.frame(width: 100)
                , alignment: .top
            )
    }
}
fileprivate extension View {
    func stepLabel(line1: String, line2: String) -> some View {
        modifier(StepLabel(line1: line1, line2: line2))
    }
}

fileprivate extension ShareDestination {
    var link: String {
        switch self {
        case .wechat: return "weixin://"
        case .qq: return "mqq://"
        case .weibo: return "sinaweibo://"
        }
    }
    
    var imageName: String {
        switch self {
        case .wechat: return "icon.wechat"
        case .qq: return "icon.qq"
        case .weibo: return "icon.weibo"
        }
    }
    
    var appName: String {
        switch self {
        case .wechat: return "微信"
        case .qq: return "QQ"
        case .weibo: return "微博"
        }
    }
}

struct InviteView_Previews: PreviewProvider {
    static var previews: some View {
        InviteView()
            .environmentObject(AccountService().withAccount())
    }
}

fileprivate extension AccountService {
    func withAccount() -> AccountService {
        self.account = .standalone
        return self
    }
}
