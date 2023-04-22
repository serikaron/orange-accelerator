//
//  View+erase.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
