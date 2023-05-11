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
    
    @State private var loading = false
    
    var body: some View {
        ZStack {
            VStack {
                NavigationTitleView(title: page.title)
                if url != nil || htmlContent != nil {
                    _WebView(request: url, htmlContent: htmlContent, loading: $loading)
                }
                Spacer()
            }
            if loading {
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
    
    @Binding var loading: Bool
    
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
        Coordinator(loading: $loading)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var loading: Bool
        
        init(loading: Binding<Bool>) {
            self._loading = loading
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            loading = true
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            loading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loading = false
        }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(page: .customService)
        WebView(page: .privacy)
    }
}
