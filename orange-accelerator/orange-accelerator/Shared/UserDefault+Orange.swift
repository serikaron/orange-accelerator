//
//  UserDefault+Orange.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import Foundation

extension UserDefaults {
    static var orange: UserDefaults = {
        UserDefaults.init(suiteName: "orange")!
    }()
}
