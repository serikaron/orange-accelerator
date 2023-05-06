//
//  EndpointService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation

@MainActor
class EndpointService: ObservableObject {
    
    
    func loadEndpoints() async {
        do {
            let serverList = try await Linkman.shared.getServerList()
            print("serverList: \(serverList)")
        } catch {
            print("loadEndpoints: \(error)")
        }
    }
}
