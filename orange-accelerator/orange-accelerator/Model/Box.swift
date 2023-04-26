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
}
