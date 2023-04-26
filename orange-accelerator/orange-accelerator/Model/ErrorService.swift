//
//  Model+ErrorView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import Foundation
import Combine
import SwiftUI

extension Model {
    func onErrorViewAppear() {
        withAnimation(.linear(duration: 0.3)) {
            errorViewAlpha = 1
        }
    }
    
    func resetErrorViewTimer() {
        print("resetErrorViewTimer")
        vanTimer?.invalidate()
        cleanTimer?.invalidate()
        
        vanTimer = Timer.scheduledTimer(
            withTimeInterval: 1.7, repeats: false,
            block: { timer in
                print("vanTimer")
                withAnimation(.linear(duration: 0.3)) { [weak self] in
                    self?.errorViewAlpha = 0
                }
            })
        cleanTimer = Timer.scheduledTimer(
            withTimeInterval: 2, repeats: false, block: { [weak self] timer in
                self?.errorMessage = nil
            })
    }
}

@MainActor
class ErrorService: ObservableObject {
    @Published var showError = false
    @Published var errorMessage: String? = nil
    
    var timer: Cancellable? {
        willSet {
            timer?.cancel()
        }
    }
    
    init() {
        Box.shared.errorSubject
            .map { $0?.localizedDescription }
            .assign(to: &$errorMessage)
        Box.shared.errorSubject
            .map { $0 != nil }
            .assign(to: &$showError)
        Box.shared.errorSubject
            .filter { $0 != nil }
            .delay(for: 3, scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: &$showError)
    }
}
