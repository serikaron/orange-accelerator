//
//  Codable+JSON.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/18.
//

import Foundation

extension Encodable {
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}
