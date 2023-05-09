//
//  OrangeButton.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI

struct OrangeButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .orangeText(size: 16, color: .white)
            .background(Color.main)
            .cornerRadius(25)
    }
}

struct OrangeButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("登录") {}
            .previewDisplayName("Button")
            .buttonStyle(OrangeButton())
    }
}
