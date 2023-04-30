//
//  V2Service.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import Foundation
import NetworkExtension

enum RouteMode {
    case global, intellegent
}

@MainActor
class V2Service: ObservableObject {
    @Published var mode = RouteMode.global
    @Published var state = State.initial
    
    enum State {
        case initial, installed, enabled, ready
    }
    
    private var manager: NETunnelProviderManager? = nil
    
    func loadConfig() async {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            manager = managers.isEmpty ? nil : managers[0]
            if let manager = manager {
                state = manager.isEnabled ? .enabled : .installed
            } else {
                state = .initial
            }
            
        } catch {
            print("loadConfig: \(error)")
        }
    }
    
    func inatallProfile() async {
        do {
            let manager = makeManager()
            try await manager.saveToPreferences()
            self.manager = manager
            state = .installed
        } catch {
            print("installProfile: \(error)")
        }
    }
    
    private func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "橙子加速器"
        
        // Configure a VPN protocol to use a Packet Tunnel Provider
        let proto = NETunnelProviderProtocol()
        // This must match an app extension bundle identifier
//        proto.providerBundleIdentifier = "orange.dev.orange-extension"
        // Replace with an actual VPN server address
//        proto.serverAddress = "27.124.9.79:10086"
//        proto.serverAddress = "27.124.9.79"
        proto.serverAddress = "127.0.0.1"
        // Pass additional information to the tunnel
        proto.providerConfiguration = [:]
        
        manager.protocolConfiguration = proto
        
        return manager
    }
    
    func enable() async {
        do {
            guard let manager = manager else {
                throw "must install profile first"
            }
            
            manager.isEnabled = true
            try await manager.saveToPreferences()
            state = .enabled
        } catch {
            print("enable: \(error)")
        }
    }
    
    func sayHelloToTunnel() {
        do {
            guard
                let tunnel = manager,
                let session = tunnel.connection as? NETunnelProviderSession,
                let message = "Hello Provider".data(using: String.Encoding.utf8), tunnel.connection.status != .invalid
            else {
                return
            }
            
            try session.sendProviderMessage(message) { [weak self] data in
                if let data = data,
                   let str = String(data: data, encoding: .utf8)
                {
                    print("provider message: \(str)")
                } else {
                    print("provider did not response message")
                }
                
                self?.state = .ready
            }
            
        } catch {
            print("sayHelloToTunnel: \(error)")
        }
    }
    
    func start() {
        guard let manager = self.manager else { return }
        
        do {
            try manager.connection.startVPNTunnel()
        } catch {
            print("start: \(error)")
        }
    }
}
