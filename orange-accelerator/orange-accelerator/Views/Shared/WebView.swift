//
//  WebView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    
    let request: String?
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let str = request,
              let url = URL(string: str)
        else {
            Box.sendError("INVALID url: \(request ?? "")")
            return
        }
        
        uiView.load(URLRequest(url: url))
    }
    
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(request: "https://www.baidu.com")
    }
}
