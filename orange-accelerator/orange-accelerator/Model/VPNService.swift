//
//  VPNService.swift
//  vDemo
//
//  Created by serika on 2022/5/12.
//

import Foundation
import NetworkExtension
import Combine

enum VPNError: Error {
    case intervalError
}

class V2Client {
    static let shared = V2Client()
    
    typealias Response = AnyPublisher<NETunnelProviderManager?, Error>
    
    private var manager: NETunnelProviderManager?
    
    func loadConfig() -> Response {
        let response = PassthroughSubject<NETunnelProviderManager?, Error>()
        
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            guard error == nil else {
                print("there is an error \(error!)")
                response.send(completion: .failure(error!))
                return
            }
            
            if let managers = managers, !managers.isEmpty {
                self.manager = managers[0]
            } else {
                self.manager = nil
            }
            
            response.send(self.manager)
            response.send(completion: .finished)
        }
        
        return response.eraseToAnyPublisher()
    }
    
    func installProfile() -> Response {
        let response = PassthroughSubject<NETunnelProviderManager?, Error>()
        
        let manager = makeManager()
        manager.saveToPreferences { error in
            guard error == nil else {
                print("install vpn profile failed, \(error!)")
                response.send(completion: .failure(error!))
                return
            }

            self.manager = manager
            response.send(manager)
            response.send(completion: .finished)
        }
        
        return response.eraseToAnyPublisher()
    }
    
    private func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "vDemo"
        
        // Configure a VPN protocol to use a Packet Tunnel Provider
        let proto = NETunnelProviderProtocol()
        // This must match an app extension bundle identifier
//        proto.providerBundleIdentifier = "test.v2ray.demo.vDemo-tunnel"
        // Replace with an actual VPN server address
//        proto.serverAddress = "27.124.9.79:10086"
//        proto.serverAddress = "27.124.9.79"
        proto.serverAddress = "127.0.0.1"
        // Pass additional information to the tunnel
        proto.providerConfiguration = [:]
        
        manager.protocolConfiguration = proto
        
        return manager
    }
    
    func start() {
        guard let manager = self.manager else { return }
        
        do {
            try manager.connection.startVPNTunnel()
        } catch {
            print("sth error")
            print(error)
        }
    }
    
    func update(isEnable: Bool) -> Response {
        let response = PassthroughSubject<NETunnelProviderManager?, Error>()
        
        guard let manager = manager else {
            DispatchQueue.main.async {
                response.send(completion: .failure(VPNError.intervalError))
            }
            return response.eraseToAnyPublisher()
        }

        manager.isEnabled = isEnable
        manager.saveToPreferences() { error in
            guard error == nil else {
                print("enable vpn profile failed, \(error!)")
                response.send(completion: .failure(error!))
                return
            }
            
            manager.loadFromPreferences { error in
                guard error == nil else {
                    print("reload vpn profile failed, \(error!)")
                    response.send(completion: .failure(error!))
                    return
                }
                
                response.send(manager)
                response.send(completion: .finished)
            }
        }

        return response.eraseToAnyPublisher()
    }
    
    func sayHelloToTunnel() {
        // Send a simple IPC message to the provider, handle the response.
        guard
            let tunnel = manager,
            let session = tunnel.connection as? NETunnelProviderSession,
            let message = "Hello Provider".data(using: String.Encoding.utf8), tunnel.connection.status != .invalid
        else {
            return
        }

        do {
            try session.sendProviderMessage(message) { response in
                if response != nil {
                    let responseString = NSString(data: response!, encoding: String.Encoding.utf8.rawValue)
                    NSLog("Received response from the provider: \(String(describing: responseString))")
                } else {
                    NSLog("Got a nil response from the provider")
                }
            }
        } catch {
            NSLog("Failed to send a message to the provider")
        }
    }
}
