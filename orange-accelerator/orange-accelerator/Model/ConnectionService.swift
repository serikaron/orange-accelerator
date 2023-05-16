//
//  ConnectionService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/11.
//

import Foundation
import NetworkExtension

enum ConnectionStatus {
    case disconnected, connecting, connected(Date)
}

@MainActor
class ConnectionService: ObservableObject {
    @Published var status: ConnectionStatus = .disconnected
    
    init() {
        NotificationCenter.default.publisher(for: Notification.Name.NEVPNStatusDidChange)
            .compactMap { $0.object as? NETunnelProviderSession }
            .filter { $0.status == .connected }
            .compactMap { $0.connectedDate }
            .map { ConnectionStatus.connected($0) }
            .combineLatest($status)
            .filter {
                switch $0.1 {
                case .disconnected: return false
                default: return true
                }
            }
            .map { $0.0 }
            .assign(to: &$status)
//            .map { status -> ConnectionStatus in
//                print("VPNStatus: \(status)")
//                switch status {
//                case .connected: return .connected
//                case .connecting, .reasserting: return .connecting
//                default:
//                    return .disconnected
//                }
//            }
//            .assign(to: &$status)
    }
    
    func connect(account: Account?) async {
        do {
            guard let account = account else {
                throw "帐号出错"
            }
            status = .connecting
            try await EndpointList.all
                .filtered(isVip: account.isVip)
                .ping()
                .fastest()?
                .connect(uuid: account.uuid, routeMode: RouteMode.mode)
        } catch {
            Box.sendError(error)
        }
    }
    
    func disconnect() async {
        print("disconnect vpn")
        status = .disconnected
        await NETunnelProviderManager.stop()
    }
}

private func duration(from startTime: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute, .second], from: startTime, to: Date())
    let hours = components.hour ?? 0
    let minutes = components.minute ?? 0
    let seconds = components.second ?? 0
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
