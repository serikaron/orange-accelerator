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
    let page: WebViewPage
    
    @State private var url: String?
    @State private var htmlContent: String?
    
    var body: some View {
        VStack {
            NavigationTitleView(title: page.title)
            if url != nil || htmlContent != nil {
                _WebView(request: url, htmlContent: htmlContent)
            }
            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    url = try await page.url
                    htmlContent = try await page.htmlContent
                } catch {
                    Box.sendError(error)
                }
            }
        }
    }
}

@MainActor
struct _WebView : UIViewRepresentable {
    
    let request: String?
    let htmlContent: String?
    
    func makeUIView(context: Context) -> WKWebView  {
        let view = WKWebView()
        
        if let request = request {
            view.navigationDelegate = context.coordinator
            
            guard let url = URL(string: request) else {
                Box.sendError("INVALID url: \(request)")
                return view
            }
            
            view.load(URLRequest(url: url))
        } else if let htmlContent = htmlContent {
            view.loadHTMLString(htmlContent, baseURL: nil)
        }
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
        WebView(page: .customService)
        WebView(page: .privacy)
    }
}
