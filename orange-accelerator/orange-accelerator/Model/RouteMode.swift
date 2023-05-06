//
//  RouteMode.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/7.
//

import Foundation

enum RouteMode {
    case global, intellegent
    
    static var mode: RouteMode {
        get {
            return UserDefaults.routeMode
        }
        set(value) {
            UserDefaults.routeMode = value
        }
    }
    
    fileprivate init(value: Int?) {
        if value == 1 {
            self = .intellegent
        } else {
            self = .global
        }
    }
    
    fileprivate var value: Int {
        switch self {
        case .global: return 0
        case .intellegent: return 1
        }
    }
}

fileprivate extension UserDefaults {
    static var routeMode: RouteMode {
        get {
            RouteMode(value: UserDefaults.orange.integer(forKey: "routeMode"))
        }
        set(mode) {
            UserDefaults.orange.setValue(mode.value, forKey: "routeMode")
        }
    }
}
