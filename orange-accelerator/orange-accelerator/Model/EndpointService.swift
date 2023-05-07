//
//  EndpointService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation
import V2orange
import NetworkExtension

enum EndpointType {
    case dedicated, free
    
    init(serverType: Int) throws {
        switch serverType {
        case 1: self = .dedicated
        case 2: self = .free
        default:
            throw "FAILED to conver server type (\(serverType)) to endpoint type"
        }
    }
}

enum EndpointLatency {
    case ms(Int), timeout
    
    func toString() -> String {
        switch self {
        case .timeout: return "Timeout"
        case .ms(let ms): return "\(ms)ms"
        }
    }
}

struct Endpoint {
    let name: String
    let host: String
    let port: String
    let type: EndpointType
    var latency: EndpointLatency?
}
typealias EndpointList = [Endpoint]

extension EndpointList {
    private static var _all: EndpointList?
    
    static var all: EndpointList {
        get async throws {
            if _all != nil { return _all! }
            
            let l = try await Linkman.shared.getServerList()
                .map { server in
                    Endpoint(name: server.name, host: server.ip, port: server.port, type: try EndpointType(serverType: server.server_type))
                }
            _all = l
            return _all!
        }
    }
    
    func filtered(isVip: Bool) -> EndpointList {
        self.filter { isVip ? $0.type == .dedicated : $0.type == .free }
    }
    
    func ping() async -> EndpointList {
        var out: EndpointList = []
        for endpoint in self {
            let latency = await endpoint.ping()
            print("latency of endpoint: \(endpoint.name) - \(latency.toString())")
            out.append(Endpoint(name: endpoint.name, host: endpoint.host, port: endpoint.port, type: endpoint.type, latency: latency))
        }
        return out
    }
    
    func fastest() throws -> Endpoint? {
        print("get fastest endpoint")
        let out = self.sorted { $0.latency! < $1.latency! }
            .first
        print("fastest endpoint: \(out?.name ?? "nil")")
        return out
    }
}

extension Endpoint {
    func connect(routeMode: RouteMode) async throws {
        print("connect vpn")
        await NETunnelProviderManager.start()
    }
    
    fileprivate func ping() async -> EndpointLatency {
        await withCheckedContinuation { continuation in
            ping { latency, error in
                if error != nil {
                    continuation.resume(returning: .timeout)
                    return
                }
                
                let match = latency.range(of: #"([1-9]|[1-9][0-9]{1,2})ms"#, options: .regularExpression) != nil
                guard match else {
                    continuation.resume(returning: .timeout)
                    return
                }
                
                let idx = latency.index(latency.endIndex, offsetBy: -2)
                let numStr = latency[..<idx]
                guard let num = Int(numStr) else {
                    continuation.resume(returning: .timeout)
                    return
                }
                
                continuation.resume(returning: .ms(num))
            }
        }
    }
    
    private func ping(completion: @escaping (String, Error?) -> Void) {
        DispatchQueue.concurrentPing.async {
            var error: NSError?
            let latency = V2orangeProPing(host, &error)
            completion(latency, error)
        }
    }
}

fileprivate extension DispatchQueue {
    static let concurrentPing: DispatchQueue = {
        DispatchQueue(label: "ping", attributes: .concurrent)
    }()
}

fileprivate extension EndpointLatency {
    static func < (lhs: EndpointLatency, rhs: EndpointLatency) -> Bool {
        switch (lhs, rhs) {
        case (.timeout, .timeout): return false
        case (.timeout, .ms): return false
        case (.ms, .timeout): return true
        case let (.ms(l), .ms(r)): return l < r
        }
    }
}
