//
//  FirstTimeRestart.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/11.
//

import Foundation

struct FirstTimeRestart {
    static var done: Bool {
        get {
            UserDefaults.orange.bool(forKey: "firstTimeRestart")
        }
        set(value) {
            UserDefaults.orange.setValue(true, forKey: "firstTimeRestart")
        }
    }
}

