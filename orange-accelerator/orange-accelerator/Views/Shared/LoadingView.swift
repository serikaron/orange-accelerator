//
//  LoadingView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/26.
//

import SwiftUI

struct LoadingView: View {
    @State private var show = false
    
    var body: some View {
        Group {
            if show {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .main))
                    .background(
                        Color.black
                            .opacity(0.15)
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                    )
            }
        }
        .onReceive(Box.shared.loadingSubject) { loading in
            show = loading
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoadingView()
            Button("Test") {
                Box.shared.toggleLoading()
            }
        }
    }
}

private extension Box {
    func toggleLoading() {
        self.loadingSubject.send(!self.loadingSubject.value)
    }
}
