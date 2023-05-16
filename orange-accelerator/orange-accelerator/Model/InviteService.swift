//
//  InviteService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/15.
//

import Foundation

enum ShareDestination {
    case wechat, qq, weibo
}

struct SharedItem {
    let name: String
    let prize: String
    let time: String
}
typealias SharedList = [SharedItem]

@MainActor
class InviteService: ObservableObject {
    @Published var days = 7
    @Published var sharedList = SharedList()
    
//    func shareTo(destination: ShareDestination) {
//        guard let url = URL(string: destination.link) else {
//            return
//        }
//        guard UIApplication.canOpenURL(url) else {
//            return
//        }
//    }
    
    func loadSharedList(page: Int, perPage: Int) async {
        do {
            let l = try await Linkman.shared.getUserInviteList(page: page, pageSize: perPage)
            sharedList += try l.map {
                SharedItem(name: $0.username, prize: $0.reward, time: try $0.created_at.toDateString())
            }
        } catch {
            Box.sendError(error)
        }
    }
    
    func loadPrizeDays() async {
        do {
            let prize = try await Linkman.shared.getInviteReward()
            guard let days = Int(prize) else {
                throw "会员天数不正确"
            }
            self.days = days
        } catch {
            Box.sendError(error)
        }
    }
}

fileprivate extension String {
    func toDateString() throws -> String {
        guard let out = self
            .toDate(format: "yyyy-MM-dd'T'HH:mm:ssZ")?
            .toString(format: "yyyy-MM-dd")
        else {
            throw "format date FAILED !!! \(self)"
        }
        
        return out
    }
}

fileprivate extension ShareDestination {
    var link: String {
        switch self {
        case .wechat: return "weixin://"
        case .qq: return "qq://"
        case .weibo: return "weibo://"
        }
    }
}
