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
#include <cmath>

#import <Cocoa/Cocoa.h>
#import <OSXNXLauncher-Swift.h>

#include "NXUSBDevice.hpp"
#include "fusee.h"

std::vector<std::uint8_t> loadIntermezzo()
{
    const std::string intermezzo_path = [[NSBundle mainBundle] pathForResource:@"intermezzo" ofType:@"bin"].UTF8String;
    std::fstream file(intermezzo_path, std::ios::in | std::ios::binary);
    if (file)
    {
        std::vector<std::uint8_t> intermezzo;
        file.seekg(0, std::ios::end);
        std::size_t size = file.tellg();
        file.seekg(0, std::ios::beg);
        
        intermezzo.resize(size);
        file.read(reinterpret_cast<char*>(&intermezzo[0]), size);
        return intermezzo;
    }
    
    return intermezzo;
}

std::vector<std::uint8_t> loadPayload()
{
    const std::string payload_path = [[NSBundle mainBundle] pathForResource:@"payload" ofType:@"bin"].UTF8String;
    std::fstream file(payload_path, std::ios::in | std::ios::binary);
    if (file)
    {
        std::vector<std::uint8_t> payload;
        file.seekg(0, std::ios::end);
        std::size_t size = file.tellg();
        file.seekg(0, std::ios::beg);
        
        payload.resize(size);
        file.read(reinterpret_cast<char*>(&payload[0]), size);
        return payload;
    }
    
    return fusee;
}

std::vector<std::uint8_t> createPayload(std::vector<std::uint8_t> intermezzo, std::vector<std::uint8_t> payload)
{
    const std::intptr_t RCM_PAYLOAD_ADDRESS = 0x40010000;
    const std::intptr_t INTERMEZZO_LOCATION = 0x4001F000;
    const std::intptr_t PAYLOAD_LOAD_BLOCK = 0x40020000;
    
    const std::uint32_t MAX_PAYLOAD_LENGTH = 0x30298;
    const std::uint32_t HEADER_SIZE = 0x2A8;
    
    const std::uint32_t RCM_PAYLOAD_SIZE = ceil((HEADER_SIZE + (INTERMEZZO_LOCATION - RCM_PAYLOAD_ADDRESS) + 0x1000 + fusee.size()) / 0x1000) * 0x1000;
    
    std::vector<std::uint8_t> buffer(RCM_PAYLOAD_SIZE + 0x1000);
    std::uint8_t* rcmPayload = &buffer[0];

    *reinterpret_cast<std::uint32_t*>(rcmPayload) = MAX_PAYLOAD_LENGTH;
    rcmPayload += HEADER_SIZE;
    
    for (std::intptr_t i = RCM_PAYLOAD_ADDRESS; i < INTERMEZZO_LOCATION; i += sizeof(std::uint32_t))
    {
        *reinterpret_cast<std::uint32_t*>(rcmPayload) = INTERMEZZO_LOCATION;
        rcmPayload += sizeof(std::uint32_t);
    }
    
    memcpy(rcmPayload, &intermezzo[0], intermezzo.size());
    memcpy(rcmPayload + (PAYLOAD_LOAD_BLOCK - INTERMEZZO_LOCATION), &fusee[0], fusee.size());
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
            
            
            auto intermezzo_data = loadIntermezzo();
            auto payload_data = loadPayload();
            
            std::vector<std::uint8_t> payload = createPayload(intermezzo_data, payload_data);
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
            
            auto intermezzo_data = loadIntermezzo();
            auto payload_data = loadPayload();
            
            std::vector<std::uint8_t> payload = createPayload(intermezzo_data, payload_data);
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
