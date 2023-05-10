//
//  NavigationService.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/10.
//

import Foundation

@MainActor
class NavigationService: ObservableObject {
    @Published var webPage: WebViewPage?
}
