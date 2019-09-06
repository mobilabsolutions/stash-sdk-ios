//
//  ThreeDSWebViewController.swift
//  Stash
//
//  Created by Borna Beakovic on 28/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit
import WebKit

public protocol ThreeDSWebViewControllerDelegate: AnyObject {
    /// Invoked when the 3DS authentication completes successfully
    func didProvide(paRes: String, md: String)

    /// Invoked when the 3DS authentication finishes with an error
    func didFail(with error: Error)
}

public class ThreeDSWebViewController: UIViewController {
    public weak var delegate: ThreeDSWebViewControllerDelegate?

    private var webView: UIWebView

    private let paReq: String
    private let md: String
    private let acsUrl: String
    private let termUrl: String

    public init(paReq: String, md: String, acsUrl: String, termUrl: String) {
        self.paReq = paReq
        self.md = md
        self.acsUrl = acsUrl
        self.termUrl = termUrl
        self.webView = UIWebView(frame: CGRect.zero)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let webView = UIWebView(frame: self.view.frame)
        webView.delegate = self
        self.webView = webView
        self.view.addSubview(self.webView)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // create HTML String
        let webViewHTMLString = String(format: "<html><body><form name='redirectToIssuerForm' id='redirectToIssuerForm' action='%@' method='post'><input type='hidden' name='PaReq' value='%@' /><input type='hidden' name='TermUrl' value='%@' /><input type='hidden' name='MD' value='%@' /><input type='submit' id='submitButton' value='Click here to continue' /></form><script>function submitForm(){document.getElementById('submitButton').style.display='none'; document.getElementById('submitButton').click();} window.onload = (function(){submitForm();});</script></body></html>", acsUrl, paReq, termUrl, md)

        self.webView.loadHTMLString(webViewHTMLString, baseURL: nil)
    }
}

extension ThreeDSWebViewController: UIWebViewDelegate {
    public func webView(_: UIWebView, didFailLoadWithError error: Error) {
        print("Web error \(error.localizedDescription)")
        self.delegate?.didFail(with: StashError.other(.from(error: error)))
        self.navigationController?.popViewController(animated: true)
    }

    public func webView(_: UIWebView, shouldStartLoadWith request: URLRequest, navigationType _: UIWebView.NavigationType) -> Bool {
        if let url = request.url, url.absoluteString.hasPrefix("https://mobilabsolutions.com"),
            let httpBody = request.httpBody,
            let receivedAuthenticationData = String(data: httpBody, encoding: String.Encoding.utf8) {
            print("3DS data: \(receivedAuthenticationData)")

            if let md = receivedAuthenticationData.components(separatedBy: "&").first?.components(separatedBy: "=").last,
                let paRes = receivedAuthenticationData.components(separatedBy: "&").last?.components(separatedBy: "=").last?.removingPercentEncoding {
                self.delegate?.didProvide(paRes: paRes, md: md)
                self.navigationController?.popViewController(animated: true)
                return false
            }
        }

        return true
    }
}
