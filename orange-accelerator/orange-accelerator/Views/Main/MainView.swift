//
//  MainView.swift
//  orange-accelerator
//
//  Created by serika on 2023/4/27.
//

import SwiftUI

private let MENU_WIDTH: CGFloat = 275

struct MainView: View {
    @StateObject private var accountService = AccountService()
    
    @State private var showSideMenu = false
    
    @State private var maskAlpha: Double = 0
    @State private var sideMenuOffset: CGFloat = -MENU_WIDTH
    
    var body: some View {
        ZStack {
            MainContentView(showSideMenu: $showSideMenu)
            Color.black.opacity(maskAlpha)
                .ignoresSafeArea()
                .onTapGesture {
                    showSideMenu = false
                }
            GeometryReader { geometry in
                Group {
                    Color.white
                        .ignoresSafeArea()
                    SideMenuView()
                }
                .frame(width: MENU_WIDTH)
                .offset(x: sideMenuOffset, y: 0)
            }
        }
        .onChange(of: showSideMenu) { isShow in
            withAnimation {
                maskAlpha = isShow ? 0.5 : 0
                sideMenuOffset = isShow ? 0 : -MENU_WIDTH
            }
        }
        .environmentObject(accountService)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
