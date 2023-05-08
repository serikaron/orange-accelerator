//
//  PacketTunnelProvider.swift
//  orange-tunnel
//
//  Created by serika on 2023/4/30.
//

import NetworkExtension
import V2orange

class PacketTunnelProvider: NEPacketTunnelProvider {

    let serverIp = "27.124.9.79"
    
    func tunToUDP() {
        
        weak var weakSelf = self
        self.packetFlow.readPackets { (packets: [Data], protocols: [NSNumber]) in
            for packet in packets {
                V2orangeInputPacket(packet)
                
            }
            
            // Recursive to keep reading
            weakSelf!.tunToUDP()
        }
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard let config = options?["config"] as? Data else {
            completionHandler("config NOT found !!!")
            return
        }
        
        var err: NSError?
        V2orangeStartV2Ray(self, config, &err)
        if err != nil {
            completionHandler(err)
            return
        }
        
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverIp)
        networkSettings.mtu = 1480

        let ipv4Settings = NEIPv4Settings(addresses: [serverIp], subnetMasks: ["255.255.255.0"])
            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        let dnsSetting = NEDNSSettings.init(servers: ["8.8.8.8","8.8.4.8"])

        networkSettings.ipv4Settings = ipv4Settings
        networkSettings.dnsSettings = dnsSetting

        setTunnelNetworkSettings(networkSettings) { (error) in
            guard error == nil else {
                completionHandler(error)
                NSLog(error?.localizedDescription ?? "")
                return
            }
            completionHandler(nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tunToUDP()
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
//    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
//        // Add code here to handle the message.
//        if let handler = completionHandler {
//            handler(messageData)
//        }
//    }
//
//    override func sleep(completionHandler: @escaping () -> Void) {
//        // Add code here to get ready to sleep.
//        completionHandler()
//    }
//
//    override func wake() {
//        // Add code here to wake up.
//    }
}

extension PacketTunnelProvider: V2orangePacketFlowProtocol{
    func writePacket(_ packet: Data?) {
        guard let packet = packet else {
            return
        }

//        self.packetFlow.writePackets([packet],withProtocols: [NSNumber](repeating: AF_INET as NSNumber, count: 1))
        
        self.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
//        self.packetFlow.writePacketObjects([packet])
        
    }
    
    
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
