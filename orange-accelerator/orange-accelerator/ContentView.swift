//
//  ContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            content
            if model.isLoading {
                OrangeProgress()
                    .background(
                        Color.black
                            .opacity(0.15)
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                    )
            }
            if model.errorMessage != nil {
                ErrorView()
                    .environmentObject(model)
            }
        }
    }
    
    private var content: some View {
        Group {
            if model.isLoggedIn {
                Text("Loggined")
            } else {
                LoginView()
                    .environmentObject(model)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Model())
            .previewDisplayName("MainContent")
        ContentView()
            .environmentObject(
                Model().withErrorMessage(Model.LoginError.invalidPassword.message)
            )
            .previewDisplayName("Error")
        ContentView()
            .environmentObject(Model().withLoading())
            .previewDisplayName("Loading")
    }
}

fileprivate extension Model {
    func withErrorMessage(_ errorMessage: String) -> Model {
        self.errorMessage = errorMessage
        return self
    }
    func withLoading() -> Model {
        self.isLoading = true
        return self
    }
}

