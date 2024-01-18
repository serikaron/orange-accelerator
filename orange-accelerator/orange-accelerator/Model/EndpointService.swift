//
//  EndpointService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/6.
//

import Foundation
import V2orange
import NetworkExtension

private struct S: Decodable {
    let ps: String
    let add: String
    let port: String
    let id: String
}

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
    case ms(Double), timeout
    
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
    let group: String
    let id: String?
}
typealias EndpointList = [Endpoint]

extension EndpointList {
    private static var _all: EndpointList?
    
    static var all: EndpointList {
        get async throws {
            try await Linkman.shared.getServerList()
                .map { server in
                    Endpoint(name: server.name, host: server.ip, port: server.port, type: try EndpointType(serverType: server.server_type), group: server.group, id: nil)
                }
            
//            if let l = _all {
//                return l
//            }
//
//            try await EndpointList.refresh()
//            return _all ?? []
        }
    }
    
    static func refresh() async throws {
        print("endpoint list refreshing ...")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                print("1")
                guard let url = URL(string: "https://156.251.183.247:1886/api/v1/client/subscribe?token=a15e174954a2137a34e701737dd3a40d") else {
                    throw "refresh endpoint list FAILED!!!"
                }
                print("2")
                
                let contents = try String(contentsOf: url)
                print("3")
                let decodedStr = try contents.base64Decoded()
                _all = decodedStr.components(separatedBy: "\r\n")
                    .filter { url in
                        url.hasPrefix("vmess://")
                    }
                    .map { vmess in
                        String(vmess[vmess.index(vmess.startIndex, offsetBy: 8)..<vmess.endIndex])
                    }
                    .compactMap { base64 in
                        do {
                            return try base64.base64Decoded()
                        } catch {
                            return nil
                        }
                    }
                    .map { info in
                        let s = try! JSONDecoder().decode(S.self, from: info.data(using: .utf8)!)
                        return Endpoint(name: s.ps, host: s.add, port: s.port, type: .dedicated, group: "", id: s.id)
                    }
                continuation.resume()
            } catch (let e) {
                print(e)
                continuation.resume(throwing: e)
            }
        }
    }
    
    func filtered(isVip: Bool) -> EndpointList {
        self.filter { isVip ? $0.type == .dedicated : $0.type == .free }
    }
    
    func ping() async -> EndpointList {
        var out: EndpointList = []
        
        await withTaskGroup(of: Endpoint.self) { group in
            for endpoint in self {
                group.addTask {
                    endpoint.withLatency(endpoint.blocksPing())
                }
            }
            // 等待所有ping操作完成
            for await result in group {
                out.append(result)
            }
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
    func connect(uuid: String, routeMode: RouteMode) async throws {
        print("connect vpn with uuid: \(uuid)")
        guard let port = Int(port) else {
            throw "INVALID v2 port (\(self.port))"
        }
        #warning("fakeUUID just for test")
        let fakeUUID = "073c3ae5-4868-3da4-8d8d-ff1e29ed974f"
        let v2Config = V2.BuildConfig(name: name, address: host, port: port, userId: uuid, usingRoute: routeMode == .intellegent)
        let data = try v2Config.encoded()
        await NETunnelProviderManager.start(config: data)
    }
    
    fileprivate func ping() async -> EndpointLatency {
        await withCheckedContinuation { continuation in
            ping { latency, error in
                if error != nil {
                    continuation.resume(returning: .timeout)
                    return
                }
                
                let num = latency.latencyNum
                
                if num == nil || num == 0 {
                    continuation.resume(returning: .timeout)
                } else {
                    continuation.resume(returning: .ms(num!))
                }
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
    
    func blocksPing() -> EndpointLatency {
        print("ping \(host) ...")
        var error: NSError?
        let latencyStr = V2orangeProPing(host, &error)
        let latencyNum = latencyStr.latencyNum
        print("ping \(host) end, latency: \(latencyNum ?? 0)")
        return latencyNum == nil || latencyNum == 0 ? .timeout : .ms(latencyNum!)
    }
    
    func withLatency(_ latency: EndpointLatency) -> Endpoint {
        Endpoint(name: name, host: host, port: port, type: type, latency: latency, group: group, id: nil)
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

fileprivate extension String {
    var latencyNum: Double? {
        let suffix = "ms"
        guard hasSuffix(suffix) else { return nil }
        let startIndex = index(startIndex, offsetBy: 0)
        let endIndex = index(endIndex, offsetBy: -suffix.count)
        let numericPart = self[startIndex..<endIndex]
        return Double(numericPart)
    }
}
