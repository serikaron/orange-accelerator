//
//  ContentView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject var account = Account()
    
    var body: some View {
        if account.isLogged {
            Text("Loggined")
        } else {
            LoginView()
                .environmentObject(account)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
