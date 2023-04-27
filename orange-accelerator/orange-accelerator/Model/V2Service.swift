//
//  V2Service.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import Foundation

enum RouteMode {
    case global, intellegent
}

class V2Service: ObservableObject {
    @Published var mode = RouteMode.global
}
