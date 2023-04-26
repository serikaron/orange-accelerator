//
//  ErrorView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import SwiftUI

struct ErrorView: View {
    @StateObject private var service = ErrorService()
    
    @State private var alpha: Double = 0
    
    var body: some View {
        Text(service.errorMessage ?? "")
            .padding(15)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(15)
            .opacity(alpha)
            .onReceive(service.$showError) { show in
                print("onChange")
                withAnimation {
                    alpha = show ? 1 : 0
                }
            }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
