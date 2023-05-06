//
//  V2Config.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/7.
//

import Foundation

enum V2 {
    struct Config: Codable {
        let `protocol`: String
        let settings: Settings
        let streamSettings: StreamSettings
        let mux: Mux
    }
    
    struct Mux: Codable {
        let enable: Bool
    }
    
    struct StreamSettings: Codable {
        let network: String
    }
    
    struct Settings: Codable {
        let vnext: [Vnext]
    }
    
    struct Vnext: Codable {
        let name: String
        let address: String
        let port: Int
        let users: [User]
    }
    
    struct User: Codable {
        let id: String
        let alterId: Int
    }
}

extension V2.Config {
    init(name: String, address: String, port: Int, userId: String) {
        self = V2.Config(
            protocol: "vmess",
            settings: V2.Settings(vnext: [
                V2.Vnext(name: name, address: address, port: port, users: [
                    V2.User(id: userId, alterId: 0)
                ])
            ]),
            streamSettings: V2.StreamSettings(network: "tcp"),
            mux: V2.Mux(enable: true)
        )
    }
}
