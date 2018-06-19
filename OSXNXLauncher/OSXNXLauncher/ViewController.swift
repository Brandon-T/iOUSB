//
//  ViewController.swift
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

import Cocoa

@objc
class Logger: NSObject {
    private var logTextView: NSTextView!
    
    func setLogView(_ logView: NSTextView) {
        logTextView = logView
    }
    
    @objc
    func appendString(_ string: String) {
        DispatchQueue.main.async {
            let text = self.logTextView.string
            self.logTextView.string = text + string
        }
    }
    
    @objc
    func appendStrings(_ strings: [String]) {
        DispatchQueue.main.async {
            strings.forEach({
                let text = self.logTextView.string
                self.logTextView.string = text + $0
            })
        }
    }
    
    @objc
    func clear() {
        DispatchQueue.main.async {
            self.logTextView?.string = ""
        }
    }
}

class ViewController: NSViewController {
    
    private let logTextView = NSTextView()
    private let refreshButton = SYFlatButton()
    private let clearButton = SYFlatButton()
    
    @objc
    public static let logger = Logger()
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Device Log"
        
        ViewController.logger.setLogView(logTextView)
        ViewController.logger.appendString("Ready Whenever You Are..\n\n");
        setupUI()
    }
}

extension ViewController {
    func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        let footerView = { () -> NSView in
            let view = NSView()
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.15).cgColor
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
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .center
        
        refreshButton.momentary = true
        refreshButton.borderNormalColor = .blue
        refreshButton.borderHighlightColor = .clear
        refreshButton.titleNormalColor = .white
        refreshButton.titleHighlightColor = .white
        refreshButton.backgroundNormalColor = .blue
        refreshButton.backgroundHighlightColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        refreshButton.cornerRadius = 5.0
        refreshButton.borderWidth = 1.0
        refreshButton.attributedTitle = NSAttributedString(string: "Reload",
                                                           attributes: [.foregroundColor: NSColor.white,
                                                                        .paragraphStyle: paragraphStyle])
        refreshButton.target = self
        refreshButton.action = #selector(onReload(_:))
        
        clearButton.momentary = true
        clearButton.borderNormalColor = .blue
        clearButton.borderHighlightColor = .clear
        clearButton.titleNormalColor = .white
        clearButton.titleHighlightColor = .white
        clearButton.backgroundNormalColor = .blue
        clearButton.backgroundHighlightColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        clearButton.cornerRadius = 5.0
        clearButton.borderWidth = 1.0
        clearButton.attributedTitle = NSAttributedString(string: "Clear",
                                                           attributes: [.foregroundColor: NSColor.white,
                                                                        .paragraphStyle: paragraphStyle])
        clearButton.target = self
        clearButton.action = #selector(onClear(_:))
        
        logTextView.wantsLayer = true
        logTextView.isEditable = false
        logTextView.isSelectable = false
        logTextView.isHorizontallyResizable = false
        logTextView.isVerticallyResizable = false
        logTextView.textContainerInset = NSSize(width: 10.0, height: 10.0)
        logTextView.layer?.borderColor = NSColor.lightGray.cgColor
        logTextView.layer?.borderWidth = 1.0
        
        view.addSubview(logTextView)
        view.addSubview(footerView)
        
        NSLayoutConstraint.activate([
            logTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0),
            logTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0),
            logTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15.0),
            
            footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            footerView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 15.0),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
    }
    
    @objc
    private func onReload(_ button: NSButton) {
        DispatchQueue.global().async {
            Smash.smash()
        }
    }
    
    @objc
    private func onClear(_ button: NSButton) {
        ViewController.logger.clear()
        ViewController.logger.appendString("Log Cleared..\n\n");
    }
}

