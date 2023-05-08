//
//  VPNService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation
import NetworkExtension

extension NETunnelProviderManager {
    @MainActor
    static func requestPermission() async {
        do {
            if try await loadPreferences() != nil {
                return
            }
            _ = try await inatallPreferences()
        } catch {
            Box.sendError(error)
        }
    }

    private static var manager: NETunnelProviderManager {
        get async throws {
            if let manager = try await loadPreferences() {
                return manager
            }
            return try await inatallPreferences()
        }
    }
    
    private static func loadPreferences() async throws -> NETunnelProviderManager? {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        return managers.isEmpty ? nil : managers[0]
    }
    
    private static func inatallPreferences() async throws -> NETunnelProviderManager {
        let manager = makeManager()
        manager.isEnabled = true
        try await manager.saveToPreferences()
        return manager
    }
    
    private static func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "橙子加速器"
        
        let proto = NETunnelProviderProtocol()
        proto.serverAddress = "127.0.0.1"
        proto.providerConfiguration = [:]
        
        manager.protocolConfiguration = proto
        
        return manager
    }
    
    private static func enable() async throws {
        let manager = try await manager
        if manager.isEnabled { return }
        manager.isEnabled = true
        try await manager.saveToPreferences()
    }
    
    private static func sayHelloToTunnel() async throws {
        _ = try await send(data: "Hello Provider".data(using: String.Encoding.utf8))
    }
        
    private static func send(data: Data?) async throws -> Data? {
        let tunnel = try await manager
        
        guard
            let session = tunnel.connection as? NETunnelProviderSession,
            let data = data, tunnel.connection.status != .invalid
        else {
            throw "send message to tunnel FAILED !!!"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try session.sendProviderMessage(data) { data in
                    continuation.resume(returning: data)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    @MainActor
    static func start(config: Data) async {
        do {
            try await enable()
            try await sayHelloToTunnel()
            try await manager.connection.startVPNTunnel(options: ["config": config] as [String: NSObject])
        } catch {
            Box.sendError(error)
        }
    }
}
