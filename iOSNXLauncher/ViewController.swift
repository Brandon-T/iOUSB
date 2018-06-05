//
//  ViewController.swift
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

import UIKit

@objc
class Logger: NSObject {
    private var logTextView: UITextView!
    
    func setLogView(_ logView: UITextView) {
        logTextView = logView
    }
    
    @objc
    func appendString(_ string: String) {
        DispatchQueue.main.async {
            let text = self.logTextView.text ?? ""
            self.logTextView.text = text + string
        }
    }
    
    @objc
    func appendStrings(_ strings: [String]) {
        DispatchQueue.main.async {
            strings.forEach({
                let text = self.logTextView.text ?? ""
                self.logTextView.text = text + $0
            })
        }
    }
    
    @objc
    func clear() {
        DispatchQueue.main.async {
            self.logTextView?.text = nil
        }
    }
}

class ViewController: UIViewController {
    
    private let logTextView = UITextView()
    private let refreshButton = UIButton(type: .custom)
    private let clearButton = UIButton(type: .custom)
    
    @objc
    public static let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Device Log"
        
        ViewController.logger.setLogView(logTextView)
        ViewController.logger.appendString("Ready Whenever You Are..\n\n");
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        let footerView = { () -> UIView in
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
            view.addSubview(refreshButton)
            view.addSubview(clearButton)
            
            NSLayoutConstraint.activate([
                refreshButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0),
                refreshButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15.0),
                refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15.0),
                refreshButton.heightAnchor.constraint(equalToConstant: 45.0),
                refreshButton.widthAnchor.constraint(equalTo: clearButton.widthAnchor),
                
                clearButton.leftAnchor.constraint(equalTo: refreshButton.rightAnchor, constant: 15.0),
                clearButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0),
                clearButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15.0),
                clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15.0),
                clearButton.heightAnchor.constraint(equalToConstant: 45.0),
                clearButton.widthAnchor.constraint(equalTo: refreshButton.widthAnchor)
                ])
            
            view.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
            return view
        }()
        
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.backgroundColor = .blue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.setTitle("Reload", for: .normal)
        refreshButton.addTarget(self, action: #selector(onReload(_:)), for: .touchUpInside)
        
        clearButton.layer.cornerRadius = 5.0
        clearButton.backgroundColor = .blue
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(onClear(_:)), for: .touchUpInside)
        
        logTextView.isEditable = false
        logTextView.isSelectable = false
        logTextView.layer.borderColor = UIColor.lightGray.cgColor
        logTextView.layer.borderWidth = 1.0
        
        view.addSubview(logTextView)
        view.addSubview(footerView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                logTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0),
                logTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0),
                logTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15.0),
                
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 15.0),
                footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
        }
        else {
            edgesForExtendedLayout = .init(rawValue: 0)
            
            NSLayoutConstraint.activate([
                logTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0),
                logTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0),
                logTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15.0),
                
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 15.0),
                footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
        
        view.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
    }
    
    @objc
    private func onReload(_ button: UIButton) {
        DispatchQueue.global().async {
            Smash.smash()
        }
    }
    
    @objc
    private func onClear(_ button: UIButton) {
        ViewController.logger.clear()
        ViewController.logger.appendString("Log Cleared..\n\n");
    }
}

