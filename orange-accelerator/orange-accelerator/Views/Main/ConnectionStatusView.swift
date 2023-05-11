//
//  ConnectionStatusView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI
import NetworkExtension

struct ConnectionStatusView: View {
    @EnvironmentObject var service: ConnectionService
    
    @State private var duration: String = "00:00:00"
    @State private var connectedDate: Date?
    
    var body: some View {
        if service.status.show {
            VStack(spacing: 0) {
                HStack {
                    Text("链接状态：")
                        .orangeText(size: 15, color: .c000000)
                    Text(service.status.name)
                        .orangeText(size: 15, color: .hex("#02C91E"))
                }
                Spacer().frame(height: 45)
                Text(duration)
                    .orangeText(size: 15, color: .c000000)
                    .padding(.top, -20)
            }
//            .onAppear {
//                updateDuration()
//            }
//            .onChange(of: service.status) { _ in
//                updateDuration()
//            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { timer in
                self.duration = connectedDate?.distanceToNow ?? "00:00:00"
            }
            .onReceive(service.$status) { status in
                switch service.status {
                case let ConnectionStatus.connected(connectedDate):
                    self.connectedDate = connectedDate
                default:
                    self.connectedDate = nil
                }
            }
        }
    }
    
    private func updateDuration() {
        Task {
            duration = await NETunnelProviderManager.connectedDuration
        }
    }
}

fileprivate extension ConnectionStatus {
    var show: Bool {
        switch self {
        case .disconnected: return false
        default: return true
        }
    }
    
    var name: String {
        switch self {
        case .disconnected:
            return "已断开"
        case .connecting:
            return "连接中"
        case .connected:
            return "已连接"
        }
    }
}

fileprivate extension Date {
    var distanceToNow: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self, to: Date())
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct ConnectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStatusView()
            .environmentObject(ConnectionService())
    }
}
