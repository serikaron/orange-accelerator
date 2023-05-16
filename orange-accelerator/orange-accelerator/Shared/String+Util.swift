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

extension String {
    func toDate(format: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = format
        return f.date(from: self)
    }
}

extension Date {
    func toString(format: String) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: self)
    }
}
