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
    
    func copyCode() {}
    
    func copyURL() {}
    
    func shareTo(destination: ShareDestination) {}
    
    func loadSharedList(page: Int, perPage: Int) async {
        sharedList = (0..<10).map { SharedItem(name: "name\($0)", prize: "7天", time: "2022-02-02")}
    }
}
