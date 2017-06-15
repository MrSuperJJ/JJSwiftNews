//
//  NewsDetailViewController.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/30.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class JJWebViewController: UIViewController {

    // MARK: - Properties
    private lazy var wkWebview: WKWebView = {
        let config = WKWebViewConfiguration()
        let userContent = WKUserContentController()
        config.userContentController = userContent
        let wkWebview = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: config)
        return wkWebview
    }()

    private lazy var wbProgressView: UIProgressView = {
        let wbProgressView = UIProgressView(frame: CGRect(x: 0, y: NavBarHeight, width: self.view.frame.width, height: 1))
        wbProgressView.tintColor = UIColor.blue
        wbProgressView.trackTintColor = UIColor.clear
        return wbProgressView
    }()
    
    fileprivate var isNetworkReachable: Bool {
        get {
            guard NetworkReachabilityManager(host: "www.baidu.com")?.isReachable == true else {
                return false
            }
            return true
        }
    }

    internal var requestURLPath: String?
    
    private var errorRetryView: JJErrorRetryView?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 进度条配置
        wkWebview.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        self.view.addSubview(wkWebview)
        self.view.addSubview(wbProgressView)
        
        // 检查网络状态
        if isNetworkReachable {
            requestURL()
        } else {
            self.errorRetryView = JJErrorRetryView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
            if let errorRetryView = self.errorRetryView {
                errorRetryView.backgroundColor = UIColor.white
                self.view.addSubview(errorRetryView)
                
                errorRetryView.show(errorMessage: "网络异常", retryClosure: { [unowned self] in
                    if self.isNetworkReachable {
                        self.requestURL()
                        errorRetryView.hide()
                    }
                })
            }
        }
    }

    deinit {
        wkWebview.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - 进度条监听
    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            wbProgressView.isHidden = wkWebview.estimatedProgress == 1
            wbProgressView.setProgress(Float(wkWebview.estimatedProgress), animated: true)
            print(wkWebview.estimatedProgress)
        }
    }
    
    // MARK: - 请求URL
    private func requestURL() {
        if let requestURLPath = self.requestURLPath {
            let htmlRequest = URLRequest.init(url: URL.init(string: requestURLPath)!)
            wkWebview.load(htmlRequest)
        }
    }
}
