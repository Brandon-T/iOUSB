//
//  main.swift
//  OSXNXLauncher
//
//  Created by Brandon on 2018-06-18.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import Cocoa

let app = NSApplication.shared
app.setActivationPolicy(.regular)
app.delegate = AppDelegate()
app.run()
