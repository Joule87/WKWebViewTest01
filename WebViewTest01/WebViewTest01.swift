//
//  WebViewTest01.swift
//  WebViewTest01
//
//  Created by julio.collado on 11/17/23.
//

import UIKit
import SwiftUI
import WebKit
import OSLog

typealias DownloadFinished = (URL?) -> Void

@available(iOS 14.5, *)
struct WebView: UIViewRepresentable {
    let websiteURL: URL
    
    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: websiteURL)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate
@available(iOS 14.5, *)
class WebViewCoordinator: NSObject, WKNavigationDelegate {
    private lazy var logger = Logger()
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        return navigationAction.shouldPerformDownload ? decisionHandler(.download, preferences) : decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        navigationResponse.canShowMIMEType ? decisionHandler(.allow) : decisionHandler(.download)
    }
    
}

// MARK: - WKDownloadDelegate
@available(iOS 14.5, *)
extension WebViewCoordinator: WKDownloadDelegate {
        
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return
        }
        let fileUrl = documentDirectory.appendingPathComponent("\(suggestedFilename)")
        
        if fileManager.fileExists(atPath: fileUrl.path()) {
            logger.info("file already exist")
            completionHandler(nil)
        } else {
            logger.info("file path: \(fileUrl.path())")
            completionHandler(fileUrl)
        }
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        logger.info("download file succeeded")
    }
    
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        logger.error("\(error.localizedDescription)")
    }
}
