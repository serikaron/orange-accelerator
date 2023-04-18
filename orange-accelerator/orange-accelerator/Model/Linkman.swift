//
//  Linkman.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/16.
//

import Foundation

let baseURL = ""

class Linkman {
    static let shared = Linkman()
    
    var presentation = false
    var token = ""
    
    func make(request: Request) async throws -> Data? {
        if (presentation || request.forceMock),
            let mockResponse = request.mockResponse {
            return try mockResponse.encoded()
        }
        
        let r = try request.urlRequest(with: baseURL)
        let (data, _) = try await URLSession.shared.data(for: r)
        return data
    }
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

// MARK: - Request
class Request: Withable {
    typealias QueryList = [String]
    
    var path: String = ""
    var method: HTTPMethod = .GET
    var query: [String: String]?
    var body: Encodable?
    var headers: [String: String]?
    var mockResponse: Encodable?
    var forceMock: Bool = false
}

enum RequestError: Error {
    case invalidURL
    case invalidBody
}


fileprivate extension Request {
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
            throw RequestError.invalidURL
        }
        
        var out = URLRequest(url: url)
        out.httpMethod = method.rawValue
        if let body = body {
            do {
                out.httpBody = try body.encoded()
            } catch {
                print("invalid body \(body)")
                throw RequestError.invalidBody
            }
        }
        if !token.isEmpty {
            out.addValue(token, forHTTPHeaderField: "Access_Token")
        }
        out.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return out
    }
}
    
extension Request {
    func make() async throws -> Data? {
        return try await Linkman.shared.make(request: self)
    }
}

