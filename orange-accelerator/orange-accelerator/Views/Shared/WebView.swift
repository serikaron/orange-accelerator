//
//  WebView.swift
//  orange-accelerator
//
//  Created by serika on 2023/5/9.
//

import SwiftUI
import WebKit

typealias WebViewInfo = (title: String, url: String)

struct WebView: View {
    let title: String
    let url: String
    
    var body: some View {
        VStack {
            NavigationTitleView(title: title)
            _WebView(request: url)
        }
        .navigationBarHidden(true)
    }
}

@MainActor
struct _WebView : UIViewRepresentable {
    
    let request: String?
    
    func makeUIView(context: Context) -> WKWebView  {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        
        guard let str = request,
              let url = URL(string: str)
        else {
            Box.sendError("INVALID url: \(request ?? "")")
            return view
        }
        
        view.load(URLRequest(url: url))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    func makeCoordinator() -> _WebView.Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                Box.setLoading(false)
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                Box.setLoading(true)
            }
        }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(title: "测试", url: "https://www.baidu.com")
    }
}
