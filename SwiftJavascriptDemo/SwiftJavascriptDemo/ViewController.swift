//
//  ViewController.swift
//  SwiftJavascriptDemo
//
//  Created by CHEN-ZIFENG on 2018/10/25.
//  Copyright © 2018 陈_子疯. All rights reserved.
//

import UIKit
import JavaScriptCore

/// 定义协议SwiftJavaScriptDelegate 该协议必须遵守JSExport协议
@objc protocol SwiftJavaScriptDelegate:JSExport {
    func showTips(_ tips: String)
}

/// 定义一个模型 该模型实现SwiftJavaScriptDelegate协议
@objc class SwiftJavaScriptModel:NSObject,SwiftJavaScriptDelegate {
    
    weak var jsContext:JSContext?
    func showTips(_ tips: String) {
        print("测试：\(tips)")
    }
    
    
}

class ViewController: UIViewController {

    var webView = UIWebView()
    var button = UIButton()
    var jsContext = JSContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addWebView()
        addButton()
    }
    
    // 添加webview视图层
    func addWebView() {
        webView = UIWebView(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: view.bounds.height/2))
        webView.layer.borderWidth = 1
        webView.layer.borderColor = UIColor.red.cgColor
        view.addSubview(webView)
        webView.delegate = self
        webView.scalesPageToFit = true
        
        // 加载线上URL
//        let urlString = "你的线上URL地址"
//        let url = URL(string: urlString)
//        let request = URLRequest(url: url)
        
        // 加载本地HTML
        let path:String = Bundle.main.path(forResource: "Test", ofType: "html")!
        let url:URL = URL(string: path)!
        let request = URLRequest(url: url)
        
        webView.loadRequest(request)
    }

    // 添加原生button
    func addButton() {
        button = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 100, width: view.bounds.width - 40, height: 45))
        button.backgroundColor = UIColor.orange
        button.setTitle("原生Button调用JS方法", for: .normal)
        button.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func btnClick()
    {
        self.webView.stringByEvaluatingJavaScript(from: "jsAction()")
    }

}

extension ViewController:UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let model = SwiftJavaScriptModel()
        model.jsContext = self.jsContext
        
        // 这一步是将SwiftJavaScriptModel模型注入到JS中，在JS就可以通过WebViewJavascriptBridge调用我们暴露的方法了。
        self.jsContext?.setObject(model, forKeyedSubscript: "WebViewJavascriptBridge" as NSCopying & NSObjectProtocol )
    }
}

