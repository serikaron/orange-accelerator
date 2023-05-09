//
//  MemberStore.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import Foundation

struct MemberStoreItem {
    let id: Int
    let name: String
    let price: Double
    let mark: String
    
    static var all: [MemberStoreItem] {
        get async throws {
            try await Linkman.shared.getPackageList()
                .sorted { $0.sort < $1.sort }
                .map { MemberStoreItem(id: $0.id, name: $0.name, price: $0.price, mark: $0.mark) }
        }
    }
    
    @MainActor
    static func buy(with id: Int) async {
        do {
            try await Linkman.shared.buyPackage(with: id)
        } catch {
            Box.sendError(error)
        }
    }
}
