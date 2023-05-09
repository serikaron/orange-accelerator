//
//  ConnectionStatusView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI
import NetworkExtension

struct ConnectionStatusView: View {
    @Binding var status: NEVPNStatus
    
    @State private var duration: String = "00:00:00"
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if status.show {
            VStack(spacing: 0) {
                HStack {
                    Text("链接状态：")
                        .orangeText(size: 15, color: .c000000)
                    Text(status.name)
                        .orangeText(size: 15, color: .hex("#02C91E"))
                }
                Spacer().frame(height: 45)
                Text(duration)
                    .orangeText(size: 15, color: .c000000)
                    .padding(.top, -20)
            }
            .onAppear {
                updateDuration()
            }
            .onChange(of: status) { _ in
                updateDuration()
            }
            .onReceive(timer) { timer in
                guard status == .connected else { return }
                updateDuration()
            }
        }
    }
    
    private func updateDuration() {
        Task {
            duration = await NETunnelProviderManager.connectedDuration
        }
    }
}

fileprivate extension NEVPNStatus {
    var show: Bool {
        self == .connected ||
        self == .connecting ||
        self == .disconnecting ||
        self == .reasserting
    }
    
    var name: String {
        switch self {
        case .invalid:
            return "不可用"
        case .disconnected:
            return "已断开"
        case .connecting:
            return "连接中"
        case .connected:
            return "已连接"
        case .reasserting:
            return "重连中"
        case .disconnecting:
            return "断开中"
        @unknown default:
            return "不可用"
        }
    }
}

struct ConnectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStatusView(status: .constant(.connected))
    }
}
