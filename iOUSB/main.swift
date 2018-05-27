//
//  main.swift
//  iOUSB
//
//  Created by Brandon on 2018-05-21.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit


extension String: Error {}

if (!(setuid(0) == 0 && setgid(0) == 0))
{
    NSLog("Failed to gain root privileges, aborting...")
    print("Failed to gain root privileges, aborting...")
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//        let alert = UIAlertController(title: "Error", message: "Failed to gain root privileges, aborting...", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//    }
}

UIApplicationMain(CommandLine.argc, UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)), NSStringFromClass(UIApplication.self), NSStringFromClass(AppDelegate.self))
