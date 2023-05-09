//
//  NavigationTitleView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI

struct NavigationTitleView: View {
    let title: String
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Color(hex: "#EDEDED")
                    .frame(height: 1)
            }
            HStack {
                Spacer().frame(width: 16)
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("icon.back")
                }
                Spacer()
            }
            HStack {
                Text(title)
                    .orangeText(size: 16, color: .c000000)
            }
        }
        .frame(height: 44)
    }
}

struct NavigationTitleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTitleView(title: "标题")
    }
}
