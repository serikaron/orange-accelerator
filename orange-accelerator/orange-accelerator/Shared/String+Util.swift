//
//  String+Error.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/25.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
    
//    fileprivate static let phoneRegex = #"^1[3-9]\d{9}$"#

//    public var isPhone: Bool {
//        self.range(of: String.phoneRegex, options: .regularExpression) != nil
//    }
}
