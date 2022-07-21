//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  SamlViewController.swift
//  Sample
//
//  Created by safetrust on 6/2/20.
//


import GoogleSignIn
import SafetrustWalletDevelopmentKit
import PhoneNumberKit
import Foundation


class SamlViewController: BaseAuthenticationController {
    
    private final var AuthenMethod : String = "authenSaml";
    private var urlLink: String! = nil;
    private let authenticationService = SWDK.sharedInstance().authenticationService();
    private var web: WKWebView!
    
    override func loadView() {
        super.loadView()
          let webConfiguration = WKWebViewConfiguration()
         let contentController = WKUserContentController();
         contentController.add(self, name: AuthenMethod)
         webConfiguration.userContentController = contentController
         web = WKWebView(frame: .zero, configuration: webConfiguration)
         web.navigationDelegate = self
         view = web
         let fString = "function authenSaml(data){window.webkit.messageHandlers.authenSaml.postMessage(data);}"
         web.evaluateJavaScript(fString , completionHandler: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (urlLink != nil) {
            setupUrl(urlString: urlLink)
        }
    }
    private func setupUrl(urlString: String){
        if let url = URL(string: urlLink) {
            web?.configuration.preferences.javaScriptEnabled = true
            web?.load(URLRequest(url: url))
        }
    }
    
    func setup(urlString: String){
        urlLink = urlString
    }
}

extension SamlViewController: WebKit.WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (webView.url != nil){
            let fString = "function authenSaml(data){window.webkit.messageHandlers.authenSaml.postMessage(data);}"
            webView.evaluateJavaScript(fString , completionHandler: nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

