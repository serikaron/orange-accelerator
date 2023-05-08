//
//  V2Config.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/7.
//

import Foundation

enum V2 {
    struct Config: Codable {
        let outbounds: [Outbound]
    }
    
    struct Outbound: Codable {
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

    static func BuildConfig(name: String, address: String, port: Int, userId: String) -> Config {
        Config(
            outbounds: [
                Outbound(
                    protocol: "vmess",
                    settings: Settings(vnext: [
                        Vnext(name: name, address: address, port: port, users: [
                            User(id: userId, alterId: 0)
                        ])
                    ]),
                    streamSettings: StreamSettings(network: "tcp"),
                    mux: Mux(enable: true)
                )
            ]
        )
    }
}
