//
//  PLWebViewController.swift
//  Nimble
//
//  Created by Rayan Mehdi on 26/02/2019.
//

import Foundation
import UIKit
import WebKit

class PLWebViewController: UIViewController {
    
    weak var delegate: PLWebViewControllerDelegate?
    var closeButton: UIButton?
    
    lazy var webView: WKWebView = {
        let wkwv = WKWebView()
        wkwv.navigationDelegate = self
        return wkwv
    }()
    
    private lazy var progressView: UIProgressView = {
        let prv = UIProgressView(progressViewStyle: .default)
        prv.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//        prv = UIColor.appButtonPrimary
        view.addSubview(prv)
        return prv
    }()
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        let bundle = Bundle.init(for: self.classForCoder)
        if let image = UIImage.init(named: "closeIcon", in: bundle, compatibleWith: nil) {
            closeButton?.setImage(image, for: .normal)
        }
        
//        closeButton!.setTitle("close", for: .normal)
//        closeButton?.setTitleColor(.black, for: .normal)
        closeButton!.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        self.view.addSubview(closeButton!)
        closeButton?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            closeButton?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            closeButton?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        } else {
            // Fallback on earlier versions
        }
        self.view.bringSubviewToFront(closeButton!)
        self.view.sendSubviewToBack(webView)
        
        estimatedProgressObservation = webView.observe(\WKWebView.estimatedProgress, options: [NSKeyValueObservingOptions.new]) { [weak self] (_, change) in
            if let progress = change.newValue {
                self?.progressView.progress = Float(progress)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var topInset = CGFloat(0)
        if #available(iOS 11, *) {
            topInset = view.safeAreaInsets.top
        }
        progressView.frame = CGRect(x: 0, y: topInset, width: view.bounds.width, height: 2)
    }
    
    func loadUrl(_ url: URL) {
//        webView.load(URLRequest(url: url))
        tempFixLoadUrl(url)
    }
    
    // TODO: Delete me when fixed
    private func tempFixLoadUrl(_ url: URL) {
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: url))
            }
        }
    }
    
    func listenForEventNames(_ eventNames: [ScriptEvent.Name]) {
        for eventName in eventNames {
            webView.configuration.userContentController.add(self, name: eventName.rawValue)
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        progressView.removeFromSuperview()
    }
    
    @objc func close() {
        delegate?.plWebViewControllerDidRequestClose(self)
    }
    
}

// MARK: - WKWebView
extension PLWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        delegate?.plWebViewControllerDidFinishLoadingWithSuccess(self)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        delegate?.plWebViewController(self, didFinishLoadingWithError: error)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    
}

// MARK: - WKScriptMessageHandler
extension PLWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.plWebViewController(self, didReceive: message)
    }
}
