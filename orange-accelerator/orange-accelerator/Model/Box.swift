//
//  Box.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/25.
//

import Foundation
import Combine

class Box {
    static let shared = Box()
    
    let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    let loadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    let tokenSubject = CurrentValueSubject<String?, Never>(UserDefaults.token)
}

extension Box {
    @MainActor
    static func sendError(_ error: Error?) {
        Box.shared.errorSubject.send(error)
    }
    
    @MainActor
    static func setLoading(_ loading: Bool) {
        Box.shared.loadingSubject.send(loading)
    }
    
    static func setToken(_ token: String?) {
        Box.shared.tokenSubject.send(token)
    }
}
