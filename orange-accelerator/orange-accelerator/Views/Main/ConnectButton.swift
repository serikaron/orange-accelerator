//
//  ConnectButton.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/11.
//

import SwiftUI

@MainActor
struct ConnectButton: View {
    @EnvironmentObject var service: ConnectionService
    @EnvironmentObject var accountService: AccountService
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var step = 0
    
    private let alphas = [0.05, 0.1, 0.03]
    private var alpha1: Double { alphas[(step + 0) % alphas.count] }
    private var alpha2: Double { alphas[(step + 1) % alphas.count] }
    private var alpha3: Double { alphas[(step + 2) % alphas.count] }
    
    var body: some View {
        Button {
            step = 0
            Task {
                switch service.status {
                case .connected: await service.disconnect()
                case .disconnected: await service.connect(account: accountService.account)
                case .connecting: await service.disconnect()
                }
            }
        } label: {
            label
        }
    }
    
    private var label: some View {
        VStack {
            ZStack {
                circle(diameter: 194, opacity: alpha1)
                circle(diameter: 167, opacity: alpha2)
                circle(diameter: 131, opacity: alpha3)
                circle(diameter: 94, opacity: 0.01)
                Image(imageName)
            }
            .onReceive(timer) { _ in
                switch service.status {
                case .connected, .disconnected:
                    step = 0
                    break
                case .connecting:
                    withAnimation(.linear(duration: 0.5)) {
                        step = (step + 1) % alphas.count
                    }
                }
            }
        }
    }
    
    private func circle(diameter: Double, opacity: Double) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: diameter)
            Circle()
                .fill(Color.main)
                .frame(width: diameter)
                .opacity(opacity)
        }
    }
    
    private var imageName: String {
        switch service.status {
        case .disconnected: return "button.connect"
        case .connecting, .connected: return "button.disconnect"
        }
    }
}


struct ConnectButton_Previews: PreviewProvider {
    static var previews: some View {
        ConnectButton()
            .environmentObject(ConnectionService().with(state: .disconnected))
            .environmentObject(AccountService())
            .previewDisplayName("disconnected")
        ConnectButton()
            .environmentObject(ConnectionService().with(state: .connected(Date())))
            .environmentObject(AccountService())
            .previewDisplayName("connected")
        ConnectButton()
            .environmentObject(ConnectionService().with(state: .connecting))
            .environmentObject(AccountService())
            .previewDisplayName("connecting")
    }
}

fileprivate extension ConnectionService {
    func with(state: ConnectionStatus) -> Self {
        self.status = state
        return self
    }
}
