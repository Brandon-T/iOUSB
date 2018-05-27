//
//  USB.h
//  iOUSB
//
//  Created by Brandon on 2018-05-26.
//  Copyright © 2018 XIO. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A class for communicating with the USB devices through the Kernel mapping into Userspace via IOKit.
/// IOKit is shipped on all iOS devices and can be accessed by non-jailbroken devices as well.
/// Only thing I haven't tried yet is writing to a USB device on a non-jailbroken device.. but at least we can read on those :)
/// We have read-write access on jailbroken devices.
@interface USB : NSObject
- (NSArray<NSString *> *)getUSBDevices;

- (void)addDeviceListener:(void(^)(NSArray<NSString *> *info))listener;
@end
