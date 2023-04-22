//
//  ErrorView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/22.
//

import SwiftUI

struct ErrorView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        Text(model.errorMessage ?? "")
            .padding(15)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(15)
            .opacity(model.errorViewAlpha)
            .onAppear {
                model.onErrorViewAppear()
                model.resetErrorViewTimer()
            }
            .onReceive(model.$errorMessage) { msg in
                print("onReceive, msg: \(msg)")
                if msg != nil {
                    model.resetErrorViewTimer()
                }
            }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
            .environmentObject(Model.shared)
    }
}
