//
//  VPNService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation
import NetworkExtension

@MainActor
class VPNService {
    private var manager: NETunnelProviderManager? {
        get async throws {
            if _manager != nil { return _manager }
            try await loadPreferences()
            if _manager != nil { return _manager }
            try await inatallPreferences()
            return _manager
        }
    }
    
    private var _manager: NETunnelProviderManager? = nil
    
    func loadManager() async {
        do {
            _ = try await self.manager
        } catch {
            Box.sendError(error)
        }
    }
    
    private func loadPreferences() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        _manager = managers.isEmpty ? nil : managers[0]
    }
    
    private func inatallPreferences() async throws {
        let manager = makeManager()
        manager.isEnabled = true
        try await manager.saveToPreferences()
        _manager = manager
    }
    
    private func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "橙子加速器"
        
        let proto = NETunnelProviderProtocol()
        proto.serverAddress = "127.0.0.1"
        proto.providerConfiguration = [:]
        
        manager.protocolConfiguration = proto
        
        return manager
    }
    
    private func enable() async throws {
        guard let manager = try await manager else {
            throw "NETunnelProviderManager is null"
        }
        
        manager.isEnabled = true
        try await manager.saveToPreferences()
    }
    
    private func sayHelloToTunnel() async throws {
        _ = try await send(data: "Hello Provider".data(using: String.Encoding.utf8))
    }
        
    private func send(data: Data?) async throws -> Data? {
        guard
            let tunnel = try await manager,
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
    
    func start() async {
        do {
            try await enable()
            try await sayHelloToTunnel()
            guard let manager = try await manager else {
                throw "start vpn FAILED !!!"
            }
            try manager.connection.startVPNTunnel()
        } catch {
            Box.sendError(error)
        }
    }
}
