//
//  Model+Network.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import Foundation

fileprivate let baseURL = ""

private extension URLComponents {
    static func orange() -> URLComponents {
        var out = URLComponents()
        out.scheme = "http"
        out.host = ""
        return out
    }
}

enum NetworkError: Error, LocalizedError {
    case domainError(Int)
    
    var errorDescription: String? {
        switch self {
        case let .domainError(code):
            return "DomainError:{code:\(code)}"
        }
    }
}

class Linkman{
    static let shared = Linkman()
    
    var standalone = false
    var token: String? = nil
    
    struct LoginResponse: Codable {
        let access_token: String
    }
    
    func login(phone: String, password: String) async throws -> LoginResponse {
        return try await Request()
            .with(\.path, setTo: "/login")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["phone": phone, "password": password])
            .with(\.standaloneResponse, setTo: LoginResponse(access_token: "mockToken"))
            .make()
            .response()
            .decodedData() as LoginResponse
    }
    
    struct RegisterResponse: Codable {
        let access_token: String
    }
    
    func register(phone: String, password: String) async throws -> RegisterResponse {
        return try await Request()
            .with(\.path, setTo: "/register")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["phone": phone, "password": password])
            .with(\.standaloneResponse, setTo: RegisterResponse(access_token: "mockToken"))
            .make()
            .response()
            .decodedData() as RegisterResponse
    }
}

private extension Linkman {
    func make(request: Request) async throws {
        do {
            if (standalone || request.forceStandalone) {
                request._response = Response(err_code: 0, data: try request.standaloneResponse?.encoded())
                try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...200_000_000))
                return
            }
            
            var urlComponents = URLComponents.orange()
            urlComponents.path = request.path
            
            if let query = request.query {
                urlComponents.queryItems = query.map { (key, value) in
                    URLQueryItem(name: key, value: value)
                }
            }
            
            guard let url = urlComponents.url else {
                throw "invalid url: \(urlComponents.string ?? request.path)"
            }
            
            var req = URLRequest(url: url)
            req.httpMethod = request.method.rawValue
            if let body = request.body {
                req.httpBody = try body.encoded()
            }
            if let token = token {
                req.addValue(token, forHTTPHeaderField: "Access_Token")
            }
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: req)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw "not an http response"
            }
            
            guard 200 <= httpResponse.statusCode && httpResponse.statusCode < 300 else {
                throw "request failed, status: \(httpResponse.statusCode)"
            }
            
            let rsp = try data.decoded() as Response
            
            guard rsp.err_code == 0 else {
                throw NetworkError.domainError(rsp.err_code)
            }
            
            
            request._response = rsp
        } catch {
            if request.sendError {
                Box.sendError(error)
            }
            if request.throwError {
                throw error
            }
        }
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
    var body: JSONDict?
    var headers: [String: String]?

    var queryItems: [URLQueryItem] {
        guard let query = query else { return [] }
        
        return query.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
    }
    
    var standaloneResponse: Encodable?
    var _response: Response?
    var sendError = true
    var throwError = true
    var forceStandalone: Bool = false
    
    func make() async throws -> Self {
        try await Linkman.shared.make(request: self)
        return self
    }
    
    func response() throws -> Response {
        guard let r = _response else {
            throw "response not exists"
        }
        return r
    }
}

// MARK: - Response
private struct Response: Decodable {
    let err_code: Int
    let data: Data?
    
    func decodedData<T: Decodable>() throws -> T {
        guard let data = data else {
            throw "response data not exists"
        }
        return try data.decoded()
    }
}

