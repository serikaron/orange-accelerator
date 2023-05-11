//
//  Model+Network.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import Foundation

private extension URLComponents {
    static func orange() -> URLComponents {
        var out = URLComponents()
        out.scheme = "http"
        out.host = "chengzitest.daoyi365.com"
        return out
    }
}

enum NetworkError: Error, LocalizedError {
    case domainError(Int, String?)
    
    var errorDescription: String? {
        switch self {
        case let .domainError(code, msg):
            return "\(code) - \(msg ?? "")"
        }
    }
}

class Linkman{
    static let shared = Linkman()
    
    var standalone = false
    var showLog = false
    
    struct LoginResponse: Codable {
        let access_token: String
    }
    
    func login(phone: String, password: String) async throws -> LoginResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/user/login")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["username": phone, "password": password])
            .with(\.standaloneResponse, setTo: standaloneResponse(LoginResponse(access_token: "mockToken")))
            .make()
            .response() as LoginResponse
    }
    
    struct RegisterResponse: Codable {
        let access_token: String
    }
    
    func register(phone: String, password: String) async throws -> RegisterResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/user/register")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["username": phone, "password": password])
            .with(\.standaloneResponse, setTo: standaloneResponse(RegisterResponse(access_token: "mockToken")))
            .make()
            .response() as RegisterResponse
    }
    
    func userRecover(oldPassword: String, newPassword: String) async throws {
        try await Request()
            .with(\.path, setTo: "/v1/api/user/recover")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["old_password": oldPassword, "new_password": newPassword])
            .make()
    }
    
    struct ServerResonse: Codable {
        let id: Int
        let name: String
        let group: String
        let ip: String
        let port: String
        let server_type: Int
        let sort: Int
    }
    
    typealias ServerListResponse = [ServerResonse]
    
    func getServerList() async throws -> ServerListResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/server/list")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse([
                ServerResonse(id: 1, name: "live", group: "", ip: "us.60cdn.com", port: "10233", server_type: 1, sort: 0),
//                ServerResonse(id: 2, name: "dead", group: "", ip: "124.71.122.218", port: "10233", server_type: 2, sort: 0),
            ]))
            .with(\.forceStandalone, setTo: true)
            .make()
            .response() as ServerListResponse
    }
    
    struct UserInfoResponse: Codable {
        let id: Int
        let username: String
        let uuid: String
        let is_vip: Bool
        let expire_time: Int
    }
    
    func getUserInfo() async throws -> UserInfoResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/user/info")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse(UserInfoResponse(id: 1, username: "serika", uuid: "073c3ae5-4868-3da4-8d8d-ff1e29ed974f", is_vip: false, expire_time: 0)))
            .make()
            .response() as UserInfoResponse
    }
    
    struct PackageItem: Codable {
        let id: Int
        let name: String
        let price: Double
        let mark: String
        let sort: Int
    }
    
    typealias PackageItemResponse = [PackageItem]
    
    func getPackageList() async throws -> PackageItemResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/package/list")
            .with(\.method, setTo: .GET)
            .with(\.headers, setTo: ["oem": "iOS"])
            .with(\.standaloneResponse, setTo: standaloneResponse([
                PackageItem(id: 1, name: "年卡", price: 360, mark: "折合￥0.49/天", sort: 1),
                PackageItem(id: 2, name: "年卡", price: 360, mark: "折合￥0.49/天", sort: 2),
                PackageItem(id: 3, name: "年卡", price: 360, mark: "折合￥0.49/天", sort: 3),
            ]))
            .make()
            .response() as PackageItemResponse
    }
    
    func buyPackage(with id: Int) async throws {
        try await Request()
            .with(\.path, setTo: "/v1/api/buy/payurl")
            .with(\.method, setTo: .POST)
            .with(\.body, setTo: ["pak_id": id])
            .make()
    }
    
    typealias PolicyResponse = String
    
    func getPolicy() async throws -> PolicyResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/private/policy")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse("<html><body><h1>我是标题</h1>我是内容</body></html>"))
            .make()
            .response() as PolicyResponse
    }
    
    typealias OnlineServiceResponse = String
    
    func getOnlineService() async throws -> OnlineServiceResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/online/service")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse("https://www.baidu.com"))
            .make()
            .response() as OnlineServiceResponse
    }
    
    struct VersionResponse: Codable {
        let version_str: String
    }
    
    func getUpdate() async throws -> VersionResponse {
        return try await Request()
            .with(\.path, setTo: "/v1/api/update")
            .with(\.method, setTo: .GET)
            .with(\.standaloneResponse, setTo: standaloneResponse(VersionResponse(version_str: "1.1.0")))
            .make()
            .response() as VersionResponse
    }
}

private extension Linkman {
    func log(request: URLRequest){
        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"

        var requestLog = "\n---------- OUT ---------->\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            requestLog += "\n\(bodyString)\n"
        }

        requestLog += "\n------------------------->\n";
        print(requestLog)
    }
    
    func log(data: Data?, response: HTTPURLResponse?, error: Error?){

        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")

        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"

        var responseLog = "\n<---------- IN ----------\n"
        if let urlString = urlString {
            responseLog += "\(urlString)"
            responseLog += "\n\n"
        }

        if let statusCode =  response?.statusCode{
            responseLog += "HTTP \(statusCode) \(path)?\(query)\n"
        }
        if let host = components?.host{
            responseLog += "Host: \(host)\n"
        }
        for (key,value) in response?.allHeaderFields ?? [:] {
            responseLog += "\(key): \(value)\n"
        }
        if let body = data{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            responseLog += "\n\(bodyString)\n"
        }
        if let error = error{
            responseLog += "\nError: \(error.localizedDescription)\n"
        }

        responseLog += "<------------------------\n";
        print(responseLog)
    }
    
    @MainActor
    func make(request: Request) async throws {
        do {
            if (standalone || request.forceStandalone) {
                request._response = request.standaloneResponse
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
            if let token = Box.shared.tokenSubject.value {
                req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let extraHeader = request.headers {
                extraHeader.forEach { header in
                    req.addValue(header.value, forHTTPHeaderField: header.key)
                }
            }
            
            if (showLog) {
                log(request: req)
            }
            
            let (data, response) = try await URLSession.shared.data(for: req)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw "not an http response"
            }
            
            if (showLog) {
                log(data: data, response: httpResponse, error: nil)
            }
            
            guard 200 <= httpResponse.statusCode && httpResponse.statusCode < 300 else {
                throw "request failed, status: \(httpResponse.statusCode)"
            }
            
            struct Rsp: Decodable {
                let code: Int
                let msg: String?
            }
            let rsp = try data.decoded() as Rsp
            
            guard rsp.code == 0 else {
                throw NetworkError.domainError(rsp.code, rsp.msg)
            }
            
            
            request._response = data
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
    
    var standaloneResponse: Data?
    var _response: Data?
    var sendError = true
    var throwError = true
    var forceStandalone: Bool = false
    
    @discardableResult
    func make() async throws -> Self {
        try await Linkman.shared.make(request: self)
        return self
    }
    
    func response<T: Codable>() throws -> T {
        guard let r = _response else {
            throw "response not exists"
        }
        
        let rsp = try r.decoded() as Response<T>
        return rsp.data!
    }
}

// MARK: - Response
private struct Response<T: Codable>: Codable {
    let code: Int
    let data: T?
}

fileprivate func standaloneResponse<T: Codable>(_ data: T) -> Data {
    try! Response<T>(code: 0, data: data).encoded()
}

