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

#import <UIKit/UIKit.h>
#import <iOSNXLauncher-Swift.h>

#include "NXUSBDevice.hpp"
#include "fusee.h"


extern "C" {
    #import <IOKit/IOKitLib.h>
    #import <IOKit/usb/IOUSBLib.h>
    #import <IOKit/IOCFPlugIn.h>
    #import <IOKit/IOMessage.h>
    #import <IOKit/IOBSD.h>
    #import <CoreFoundation/CoreFoundation.h>
}

#include <iostream>
#include <vector>
#include <array>

std::vector<std::uint8_t> loadIntermezzo()
{
    const std::string intermezzo_path = [[NSBundle mainBundle] pathForResource:@"intermezzo" ofType:@"bin"].UTF8String ?: "";
    
    if (intermezzo_path.length())
    {
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
    }
    
    return intermezzo;
}

std::vector<std::uint8_t> loadPayload()
{
    const std::string payload_path = [[NSBundle mainBundle] pathForResource:@"payload" ofType:@"bin"].UTF8String ?: "";
    
    if (payload_path.length())
    {
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
void DeviceAdded(void *userInfo, io_iterator_t iterator);

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
    
    if (!devices.size())
    {
        CFMutableDictionaryRef matchingDict;
        io_iterator_t iter;
        kern_return_t kr;
        io_service_t device;
        
        const std::uint16_t kNintendoSwitchVendorID = 0x0955;
        const std::uint16_t kNintendoSwitchProductID = 0x7321;
        NSMutableArray *strings = [[NSMutableArray alloc] init];
        
        matchingDict = IOServiceMatching("IOUSBHostDevice"); //kIOUSBDeviceClassName for OSX but "IOUSBHostDevice" for iOS..
        if (matchingDict == nil)
        {
            return;
        }
        
        //Add Nintendo Switch
        long usbVendor = kNintendoSwitchVendorID;
        long usbProduct = kNintendoSwitchProductID;
        CFNumberRef numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
        CFDictionarySetValue(matchingDict, CFSTR(kUSBVendorID), numberRef);
        CFRelease(numberRef);

        // Create a CFNumber for the idProduct and set the value in the dictionary
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbProduct);
        CFDictionarySetValue(matchingDict, CFSTR(kUSBProductID), numberRef);
        CFRelease(numberRef);
        numberRef = nil;
        
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
        if (kr != KERN_SUCCESS)
        {
            return;
        }
        
        // Iterate over all usb devices..
        while ((device = IOIteratorNext(iter)))
        {
            io_name_t devName;
            io_name_t className;
            io_string_t pathName;
            io_string_t planeName;
            
            IORegistryEntryGetName(device, devName);
            IOObjectGetClass(device, className);
            IORegistryEntryGetPath(device, kIOServicePlane, pathName);
            IORegistryEntryGetPath(device, kIOUSBPlane, planeName);
            
            int vendorId = [[self class] getDeviceVendorId:device];
            int productId = [[self class] getDeviceProductId:device];
            NSString *serialNumber = [[self class] getDeviceSerialNumber:device];
            NSString *manufacturer = [[self class] getDeviceManufacturer:device];
            
            [strings addObject:[NSString stringWithFormat:@"Device Name: %s", devName]];
            [strings addObject:[NSString stringWithFormat:@"Device Class: %s", className]];
            [strings addObject:[NSString stringWithFormat:@"Device Plane: %s", pathName]];
            [strings addObject:[NSString stringWithFormat:@"Device Path: %s", planeName]];
            
            [strings addObject:[NSString stringWithFormat:@"VendorID: %04X", vendorId]];
            [strings addObject:[NSString stringWithFormat:@"ProductID: %04X", productId]];
            [strings addObject:[NSString stringWithFormat:@"Device Serial Number: %@", serialNumber]];
            [strings addObject:[NSString stringWithFormat:@"Device Manufacturer: %@", manufacturer]];
            
            [strings addObject:@"\n"];
            DeviceAdded(nullptr, device);
            IOObjectRelease(device);
            
            for (NSString *str : strings) {
                [ViewController.logger appendString:[NSString stringWithFormat:@"%@\n", str]];
            }
        }
        
        IOObjectRelease(iter);
    }
}

void** getInterface(io_service_t device, CFUUIDRef type, CFUUIDRef uuid)
{
    // Create a plugin interface for the device.
    IOCFPlugInInterface **plugInInterface = nil;
    SInt32 score = 0;
    
    kern_return_t kr = IOCreatePlugInInterfaceForService(device, type, kIOCFPlugInInterfaceID, &plugInInterface, &score);
    
    if ((kIOReturnSuccess != kr) || !plugInInterface)
    {
        return nil;
    }
    
    // Get a USBDeviceInterface from the plugin.. and release the plugin
    void **deviceInterface = nil;
    HRESULT res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(uuid), (LPVOID*) &deviceInterface);
    (*plugInInterface)->Release(plugInInterface);
    
    if (res || !deviceInterface)
    {
        return nil;
    }
    return deviceInterface;
};

void DeviceAdded(void *userInfo, io_iterator_t iterator)
{
    io_iterator_t usbDevice = iterator;
    
    //Function to retrieve a USBDevice interface..
    IOUSBDeviceInterface300** (^getDeviceInterface)(io_service_t) = ^IOUSBDeviceInterface300**(io_service_t device) {
        return (IOUSBDeviceInterface300 **)getInterface(device, kIOUSBDeviceUserClientTypeID, kIOUSBDeviceInterfaceID300);
    };
    
    //Function to retrieve a USBInterface interface..
    IOUSBInterfaceInterface300** (^getUSBInterface)(io_service_t) = ^IOUSBInterfaceInterface300**(io_service_t device) {
        return (IOUSBInterfaceInterface300 **)getInterface(device, kIOUSBInterfaceUserClientTypeID, kIOUSBInterfaceInterfaceID300);
    };
    // Open the USB device for communication.
    IOUSBDeviceInterface300 **deviceInterface = getDeviceInterface(usbDevice);
    if (deviceInterface)
    {
        if ((*deviceInterface)->USBDeviceOpen(deviceInterface) == kIOReturnSuccess)
        {
            //Get the configuration..
            IOUSBConfigurationDescriptorPtr config;
            kern_return_t kr = (*deviceInterface)->GetConfigurationDescriptorPtr(deviceInterface, 0, &config);
            if (kr == kIOReturnSuccess)
            {
                (*deviceInterface)->SetConfiguration(deviceInterface, config->bConfigurationValue);
                
                //Find the USB interface..
                IOUSBFindInterfaceRequest interfaceRequest;
                interfaceRequest.bInterfaceClass = kIOUSBFindInterfaceDontCare;
                interfaceRequest.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
                interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
                interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;
                
                //Get an interface iterator..
                io_iterator_t iterator;
                kr = (*deviceInterface)->CreateInterfaceIterator(deviceInterface, &interfaceRequest, &iterator);
                if (kr == kIOReturnSuccess)
                {
                    if ((usbDevice = IOIteratorNext(iterator)))
                    {
                        IOUSBInterfaceInterface300 **usbInterface = getUSBInterface(usbDevice);
                        if (usbInterface)
                        {
                            kr = (*usbInterface)->USBInterfaceOpen(usbInterface);
                            if (kr == kIOReturnSuccess) {
                                UInt8 pipe_ref = 1;
                                kr = (*usbInterface)->GetPipeStatus(usbInterface, pipe_ref);
                                switch (kr) {
                                    case kIOReturnNoDevice:
                                        [ViewController.logger appendString:@"Pipe Status: No Device"];
                                        break;
                                    case kIOReturnNotOpen:
                                        [ViewController.logger appendString:@"Pipe Status: Not Open"];
                                        break;
                                    case kIOReturnSuccess:
                                        [ViewController.logger appendString:@"Pipe Status: Open"];
                                        break;
                                    case kIOReturnBusy:
                                        [ViewController.logger appendString:@"Pipe Status: Busy"];
                                        break;
                                    default:
                                        [ViewController.logger appendString:@"Pipe Status: We screwed up"];
                                        break;
                                }
                                
                                //Testing..
//                                (*usbInterface)->WritePipe(usbInterface, pipe_ref, data, sizeof(data));
                            }
                            
                            (*usbInterface)->Release(usbInterface);
                        }
                        
                        IOObjectRelease(usbDevice);
                    }
                    
                    IOObjectRelease(iterator);
                }
            }
            
            (*deviceInterface)->USBDeviceClose(deviceInterface);
        }
        
        (*deviceInterface)->Release(deviceInterface);
    }
    
    // Cleanup
    IOObjectRelease(usbDevice);
}

+ (int)getUSBProperty:(io_service_t)device propertyName:(NSString *)propertyName {
    CFNumberRef number = (CFNumberRef)IORegistryEntryCreateCFProperty(device, (__bridge CFStringRef)(propertyName), kCFAllocatorDefault, 0);
    
    if (number) {
        int value = 0;
        CFNumberGetValue(number, kCFNumberSInt32Type, &value);
        CFRelease(number);
        return value;
    }
    return -1;
}

+ (int)getDeviceVendorId:(io_service_t)device {
    return [self getUSBProperty:device propertyName:@"idVendor"];
}

+ (int)getDeviceProductId:(io_service_t)device {
    return [self getUSBProperty:device propertyName:@"idProduct"];
}

+ (NSString *)getDeviceSerialNumber:(io_service_t)device {
    IOUSBDeviceInterface300 **deviceInterface = [self getDeviceInterface:device];
    if (deviceInterface) {
        UInt8 index;
        (*deviceInterface)->USBGetSerialNumberStringIndex(deviceInterface, &index);
        NSString *result = [self getDeviceStringDescriptor:deviceInterface index:index];
        (*deviceInterface)->Release(deviceInterface);
        return result;
    }
    return nil;
}

+ (NSString *)getDeviceManufacturer:(io_service_t)device {
    IOUSBDeviceInterface300 **deviceInterface = [self getDeviceInterface:device];
    if (deviceInterface) {
        UInt8 index;
        (*deviceInterface)->USBGetManufacturerStringIndex(deviceInterface, &index);
        NSString *result = [self getDeviceStringDescriptor:deviceInterface index:index];
        (*deviceInterface)->Release(deviceInterface);
        return result;
    }
    return nil;
}

+ (IOUSBDeviceInterface300 **)getDeviceInterface:(io_service_t)device {
    kern_return_t result;
    SInt32 score;
    IOCFPlugInInterface **plugin = nil;
    result = IOCreatePlugInInterfaceForService(device, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugin, &score);
    if (result != KERN_SUCCESS) {
        return nil;
    }
    
    IOUSBDeviceInterface300 **deviceInterface = nil;
    result = (*plugin)->QueryInterface(plugin, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (void **)&deviceInterface);
    if (result != KERN_SUCCESS) {
        IODestroyPlugInInterface(plugin);
        return nil;
    }
    IODestroyPlugInInterface(plugin);
    return deviceInterface;
}

+ (NSString *)getDeviceStringDescriptor:(IOUSBDeviceInterface300 **)deviceInterface index:(uint8_t)index {
    UInt8 requestBuffer[256];
    IOUSBDevRequest request = {
        .bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice),
        .bRequest = kUSBRqGetDescriptor,
        .wValue = static_cast<UInt16>((kUSBStringDesc << 8) | index),
        .wIndex = 0x409, //English
        .wLength = sizeof(requestBuffer),
        .pData = requestBuffer
    };
    
    kern_return_t result;
    result = (*deviceInterface)->DeviceRequest(deviceInterface, &request);
    if (result != KERN_SUCCESS) {
        return nil;
    }
    
    int strLength = requestBuffer[0] - 2;
    CFStringRef serialNumberString = CFStringCreateWithBytes(kCFAllocatorDefault, &requestBuffer[2], strLength, kCFStringEncodingUTF16LE, false);
    return (__bridge NSString *)serialNumberString;
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
