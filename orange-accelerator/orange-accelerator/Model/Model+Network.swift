//
//  Model+Network.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import Foundation

fileprivate let baseURL = ""

enum NetworkError: Error {
    case invalidURL
    case invalidBody
    case notHttpResponse
    case requestFailed
    case domainError(String)
}

extension Model {
    struct LoginResponse: Codable {
        let token: String
    }
    
    func makeLogin(phone: String, password: String) async throws -> LoginResponse {
        struct LoginBody: Encodable {
            let phone: String
            let password: String
        }
    
        return try await Request()
            .with(\.path, setTo: "/login")
            .with(\.method, setTo: .GET)
            .with(\.body, setTo: LoginBody(phone: phone, password: password))
            .with(\.standaloneRessponse, setTo: LoginResponse(token: "mockToken"))
            .make()
            .decoded() as LoginResponse
    }
}

private extension Model {
    func make(request: Request) async throws -> Data {
        if (standalone || request.forceStandalone) {
            try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...200_000_000))
            return try (request.standaloneRessponse ?? EmptyResponse()).encoded()
        }
        
        let req = try request.urlRequest(with: baseURL)
        let (data, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.notHttpResponse
        }
        
        guard 200 <= httpResponse.statusCode && httpResponse.statusCode < 300 else {
            throw NetworkError.requestFailed
        }
        
        let rsp = try data.decoded() as Response
        
        guard rsp.code == 0 else {
            throw NetworkError.domainError(rsp.message)
        }
        
        return try rsp.data ?? EmptyResponse().encoded()
    }
}

private enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

// MARK: - Request

private class Request: Withable {
    var path: String = ""
    var method: HTTPMethod = .GET
    var query: [String: String]?
    var body: Encodable?
    var headers: [String: String]?
    var standaloneRessponse: Encodable?
    var forceStandalone: Bool = false

    var queryItems: [URLQueryItem] {
        guard let query = query else { return [] }
        
        return query.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
    }
    
    
    func urlRequest(with baseURL: String, andToken token: String = "") throws -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseURL)\(path)")
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var out = URLRequest(url: url)
        out.httpMethod = method.rawValue
        if let body = body {
            do {
                out.httpBody = try body.encoded()
            } catch {
                print("invalid body \(body)")
                throw NetworkError.invalidBody
            }
        }
        if !token.isEmpty {
            out.addValue(token, forHTTPHeaderField: "Access_Token")
        }
        out.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return out
    }
    
    func make() async throws -> Data {
        return try await Model.shared.make(request: self)
    }
}

// MARK: - Response
private struct Response: Codable {
    let code: Int
    let message: String
    let data: Data?
}

struct EmptyResponse: Codable {}
