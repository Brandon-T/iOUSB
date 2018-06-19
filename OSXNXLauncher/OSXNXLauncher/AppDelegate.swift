//
//  AppDelegate.swift
//  OSXNXLauncher
//
//  Created by Brandon on 2018-06-18.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let window = NSWindow(contentRect: NSRect(x: 0.0, y: 0.0, width: 600.0, height: 600.0),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: false)
    
    private var viewController: NSViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        window.isOpaque = false
        window.center();
        window.title = "Device Log"
        window.level = .normal
        
        window.orderFrontRegardless()
        
        viewController = ViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        window.contentView?.addSubview(viewController.view)
        
        if let contentView = window.contentView {
            NSLayoutConstraint.activate([
                viewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                viewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
