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
    
    @MainActor
    let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    @MainActor
    let loadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    let tokenSubject = CurrentValueSubject<String?, Never>(UserDefaults.token)
}

extension Box {
    static func sendError(_ error: Error?) {
        Box.shared.errorSubject.send(error)
    }
    
    static func setLoading(_ loading: Bool) {
        Box.shared.loadingSubject.send(loading)
    }
    
    static func setToken(_ token: String?) {
        Box.shared.tokenSubject.send(token)
    }
}
