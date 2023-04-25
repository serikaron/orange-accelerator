//
//  String+Error.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/25.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
