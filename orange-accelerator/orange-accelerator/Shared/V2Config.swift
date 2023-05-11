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
        let routing: Routing?
    }
    
    struct Outbound: Codable {
        let `protocol`: String
        let settings: Settings
        let streamSettings: StreamSettings?
        let mux: Mux?
        let tag: String?
    }
    
    struct Mux: Codable {
        let enabled: Bool
    }
    
    struct StreamSettings: Codable {
        let network: String
    }
    
    struct Settings: Codable {
        let vnext: [Vnext]?
    }
    
    struct Vnext: Codable {
        let name: String?
        let address: String
        let port: Int
        let users: [User]
    }
    
    struct User: Codable {
        let id: String
        let alterId: Int
    }
    
    struct Rule: Codable {
        let type: String
        let outboundTag: String
        let domain: [String]?
        let ip: [String]?
    }
    
    struct Routing: Codable {
        let domainStrategy: String
        let rules: [Rule]
    }

    static func BuildConfig(name: String, address: String, port: Int, userId: String, usingRoute: Bool) -> Config {
        Config(
            outbounds: usingRoute ? [
                defaultOutbound(name: name, address: address, port: port, userId: userId),
                Outbound(protocol: "freedom", settings: Settings(vnext: nil), streamSettings: nil, mux: nil, tag: "direct")
            ] : [
                defaultOutbound(name: name, address: address, port: port, userId: userId)
            ],
            routing: usingRoute ?
            Routing(domainStrategy: "IPOnDemand", rules: [
                Rule(type: "field", outboundTag: "direct", domain: ["geosite:cn","geosite:private"], ip: nil),
//                Rule(type: "field", outboundTag: "direct", domain: nil, ip: ["geoip:cn","geoip:private"]),
            ]) : nil
        )
    }
    
    static func defaultOutbound(name: String, address: String, port: Int, userId: String) -> Outbound {
        Outbound(
            protocol: "vmess",
            settings: Settings(vnext: [
                Vnext(name: name, address: address, port: port, users: [
                    User(id: userId, alterId: 0)
                ])
            ]),
            streamSettings: StreamSettings(network: "tcp"),
            mux: Mux(enabled: true),
            tag: nil
        )
    }
}
