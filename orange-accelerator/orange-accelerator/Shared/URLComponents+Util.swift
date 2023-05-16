//
//  URLComponents+Util.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/16.
//

import Foundation

extension URLComponents {
    static func orange() -> URLComponents {
        var out = URLComponents()
        out.scheme = "http"
        out.host = "chengzitest.daoyi365.com"
        return out
    }
}
