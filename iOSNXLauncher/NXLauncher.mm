//
//  NXLauncher.cpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#include "NXLauncher.h"
#include <fstream>
#include <vector>

#import <UIKit/UIKit.h>
#import <iOSNXLauncher-Swift.h>

#include "NXUSBDevice.hpp"

std::vector<std::uint8_t> createPayload(const char* path)
{
    throw std::runtime_error("Need to implement instead of reading the binary exploit file -- provide own payload");
    
    std::vector<std::uint8_t> buffer;
    std::fstream file(path, std::ios::in | std::ios::binary);
    if (file)
    {
        file.seekg(0, std::ios::end);
        buffer.resize(file.tellg());
        file.seekg(0, std::ios::beg);
        file.read(reinterpret_cast<char*>(&buffer[0]), buffer.size());
        return buffer;
    }
    return buffer;
}


#ifdef USB_LIB_USB
@implementation Smash
+ (void)smash {
    USBDeviceManager manager = USBDeviceManager();
    auto devices = manager.list_devices();
    for (auto &device : devices)
    {
        NXUSBDevice nx_device(device.get());
        if (nx_device.isNintendoSwitch() && nx_device.isDeviceOpen())
        {
            [ViewController.logger clear];
            [ViewController.logger appendString:[NSString stringWithFormat:@"%s", nx_device.get_debug_info().c_str()]];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"bytes" ofType:@"bin"];
            std::vector<uint8_t> payload = createPayload(path.UTF8String);
            nx_device.write(payload);
            
            std::vector<uint8_t> high_buffer(0x1000, 0x00);
            nx_device.write(high_buffer);
            
            std::vector<uint8_t> smash(0x7000, 0x00);
            nx_device.control(smash);
        }
        else
        {
            [ViewController.logger clear];
            [ViewController.logger appendString:@"Other Device Detected\n\n"];
            [ViewController.logger appendString:[NSString stringWithFormat:@"%s", nx_device.get_debug_info().c_str()]];
        }
    }
}
@end
#else
@implementation Smash
+ (void)smash {
    USBDeviceManager manager = USBDeviceManager();
    auto devices = manager.GetDevicesMatching("IOUSBHostDevice", 0, 0);
    
    for (auto &device : devices)
    {
        NXUSBDevice nx_device(device.get());
        if (nx_device.isNintendoSwitch() && nx_device.isDeviceOpen())
        {
            [ViewController.logger clear];
            [ViewController.logger appendString:[NSString stringWithFormat:@"%s", nx_device.get_debug_info().c_str()]];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"bytes" ofType:@"bin"];
            std::vector<uint8_t> payload = createPayload(path.UTF8String);
            nx_device.write(payload);
            
            std::vector<uint8_t> high_buffer(0x1000, 0x00);
            nx_device.write(high_buffer);
            
            std::vector<uint8_t> smash(0x7000, 0x00);
            nx_device.control(smash);
        }
        else
        {
            [ViewController.logger clear];
            [ViewController.logger appendString:@"Other Device Detected\n\n"];
            [ViewController.logger appendString:[NSString stringWithFormat:@"%s", nx_device.get_debug_info().c_str()]];
        }
    }
}
@end
#endif
