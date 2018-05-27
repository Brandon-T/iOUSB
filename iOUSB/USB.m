//
//  USB.m
//  iOUSB
//
//  Created by Brandon on 2018-05-26.
//  Copyright © 2018 XIO. All rights reserved.
//

#import "USB.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/IOMessage.h>
@import ObjectiveC.runtime;

#define kNintendoSwitchVendorID 0x0955
#define kNintendoSwitchProductID 0x7321

struct USBNotification
{
    void* this;
    IONotificationPortRef notificationPort;
    io_iterator_t deviceIterator;
    io_object_t notification;
    CFRunLoopRef runLoop;
    void(*deviceCallback)(id this, SEL sel, NSArray<NSString *> *info);
};

// Implementation
@implementation USB

// When a device has been plugged into the phone's serial port, this function will get called..
// However, I've restricted it to just the nintendo switch.. so it will only be called if a nintendo switch is plugged in..
void DeviceAdded(void *userInfo, io_iterator_t iterator)
{
    kern_return_t kr;
    io_service_t usbDevice;
    
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    struct USBNotification *notificationInfo = (struct USBNotification *)userInfo;
    
    //Function to retrieve a USB property..
    int (^getUSBProperty)(io_service_t, NSString *) = ^int(io_service_t device, NSString *propertyName) {
        CFNumberRef number = (CFNumberRef)IORegistryEntryCreateCFProperty(device, (__bridge CFStringRef)(propertyName), kCFAllocatorDefault, 0);
        
        if (number) {
            int value = 0;
            CFNumberGetValue(number, kCFNumberSInt32Type, &value);
            CFRelease(number);
            return value;
        }
        return -1;
    };
    
    //Function to retrieve a USBDevice interface..
    IOUSBDeviceInterface** (^getDeviceInterface)(io_service_t) = ^IOUSBDeviceInterface**(io_service_t device) {
        // Create a plugin interface for the device.
        IOCFPlugInInterface **plugInInterface = nil;
        SInt32 score = 0;
        
        kern_return_t kr = IOCreatePlugInInterfaceForService(device, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
        
        if ((kIOReturnSuccess != kr) || !plugInInterface)
        {
            return nil;
        }
        
        // Get a USBDeviceInterface from the plugin.. and release the plugin
        IOUSBDeviceInterface **deviceInterface = nil;
        HRESULT res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID*) &deviceInterface);
        (*plugInInterface)->Release(plugInInterface);
        
        if (res || !deviceInterface)
        {
            return nil;
        }
        return deviceInterface;
    };
    
    // Iterate over all devices..
    while ((usbDevice = IOIteratorNext(iterator))) {
        UInt32 locationID;

        io_name_t devName;
        io_name_t className;
        io_string_t pathName;
        io_string_t planeName;
        
        IORegistryEntryGetName(usbDevice, devName);
        IOObjectGetClass(usbDevice, className);
        IORegistryEntryGetPath(usbDevice, kIOServicePlane, pathName);
        IORegistryEntryGetPath(usbDevice, kIOUSBPlane, planeName);
        int vendorId = getUSBProperty(usbDevice, [NSString stringWithUTF8String:kUSBVendorID]);
        int productId = getUSBProperty(usbDevice, [NSString stringWithUTF8String:kUSBProductID]);
        
        [strings addObject:[NSString stringWithFormat:@"Device Name: %s", devName]];
        [strings addObject:[NSString stringWithFormat:@"Device Class: %s", className]];
        [strings addObject:[NSString stringWithFormat:@"Device Plane: %s", pathName]];
        [strings addObject:[NSString stringWithFormat:@"Device Path: %s", planeName]];
        [strings addObject:[NSString stringWithFormat:@"VendorID: 0x%04X", vendorId]];
        [strings addObject:[NSString stringWithFormat:@"ProductID: 0x%04X", productId]];
        [strings addObject:@"\n"];
        
        // Get a USBDeviceInterface from the plugin.. and release the plugin
        IOUSBDeviceInterface **deviceInterface = getDeviceInterface(usbDevice);
        if (deviceInterface)
        {
            // Get the location ID from the USB Interface
            (*deviceInterface)->GetLocationID(deviceInterface, &locationID);
            [strings addObject:[NSString stringWithFormat:@"LocationID: 0x%x", locationID]];
            
            // Cleanup
            (*deviceInterface)->Release(deviceInterface);
        }
        
        
        // Register for Device Notifications.. IE: Disconnected Notification..
//        kr = IOServiceAddInterestNotification(notificationInfo->notificationPort,
//                                              usbDevice,
//                                              kIOGeneralInterest,
//                                              DeviceDisconnected,
//                                              notificationInfo,
//                                              &notificationInfo->notification
//                                              );
        
        // Cleanup
        kr = IOObjectRelease(usbDevice);
    }
    
    void(^deviceCallback)(NSArray<NSString *> *info) = (typeof(deviceCallback))imp_getBlock((IMP)notificationInfo->deviceCallback);
    deviceCallback(strings);
}

void DeviceDisconnected(void *userInfo, io_service_t service, natural_t messageType, void *messageArgument)
{
    struct USBNotification *notificationInfo = (struct USBNotification *)userInfo;
    
    if (messageType == kIOMessageServiceIsTerminated) {
        void(^deviceCallback)(NSArray<NSString *> *info) = (typeof(deviceCallback))imp_getBlock((IMP)notificationInfo->deviceCallback);
        
        deviceCallback(@[@"Device Disconnected"]);
        
        // Cleanup
        IOObjectRelease(notificationInfo->notification);
        free(userInfo);
    }
    else {
        void(^deviceCallback)(NSArray<NSString *> *info) = (typeof(deviceCallback))imp_getBlock((IMP)notificationInfo->deviceCallback);
        deviceCallback(@[@"Message Received"]);
    }
}

- (void)addDeviceListener:(void(^)(NSArray<NSString *> *info))listener {
    CFMutableDictionaryRef matchingDict = IOServiceMatching("IOUSBHostDevice");
    if (matchingDict == nil)
    {
        return;
    }
    
    // Add Nintendo Switch
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
    
    // Setup notifications for when the device is available (IE: the switch has been plugged in)
    struct USBNotification *notificationInfo = malloc(sizeof(struct USBNotification));
    notificationInfo->this = (__bridge void *)(self);
    notificationInfo->deviceCallback = (typeof(notificationInfo->deviceCallback))imp_implementationWithBlock(listener);
    notificationInfo->notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
    notificationInfo->runLoop = CFRunLoopGetCurrent();
    notificationInfo->deviceIterator = 0;
    
    CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(notificationInfo->notificationPort);
    CFRunLoopAddSource(notificationInfo->runLoop, runLoopSource, kCFRunLoopDefaultMode);
    
    // Now set up a notification to be called when a device is matched by I/O Kit.
    IOServiceAddMatchingNotification(notificationInfo->notificationPort,
                                     kIOMatchedNotification,
                                     matchingDict,
                                     DeviceAdded,
                                     notificationInfo, //userInfo
                                     &notificationInfo->deviceIterator
                                     );

    // Call for existing devices (in case device is already plugged in)
    DeviceAdded(notificationInfo, notificationInfo->deviceIterator);
}


// Manually called to list all USB device properties for the nintendo switch..
- (NSArray<NSString *> *)getUSBDevices {
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    
    CFMutableDictionaryRef matchingDict;
    io_iterator_t iter;
    kern_return_t kr;
    io_service_t device;
    
    matchingDict = IOServiceMatching("IOUSBHostDevice"); //kIOUSBDeviceClassName for OSX but "IOUSBHostDevice" for iOS..
    if (matchingDict == nil)
    {
        return nil;
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
        return nil;
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
        
        int vendorId = [self getDeviceVendorId:device];
        int productId = [self getDeviceProductId:device];
        NSString *serialNumber = [self getDeviceSerialNumber:device];
        NSString *manufacturer = [self getDeviceManufacturer:device];
        
        [strings addObject:[NSString stringWithFormat:@"Device Name: %s", devName]];
        [strings addObject:[NSString stringWithFormat:@"Device Class: %s", className]];
        [strings addObject:[NSString stringWithFormat:@"Device Plane: %s", pathName]];
        [strings addObject:[NSString stringWithFormat:@"Device Path: %s", planeName]];

        [strings addObject:[NSString stringWithFormat:@"VendorID: %04X", vendorId]];
        [strings addObject:[NSString stringWithFormat:@"ProductID: %04X", productId]];
        [strings addObject:[NSString stringWithFormat:@"Device Serial Number: %@", serialNumber]];
        [strings addObject:[NSString stringWithFormat:@"Device Manufacturer: %@", manufacturer]];

        [strings addObject:@"\n"];
        IOObjectRelease(device);
    }
    
    IOObjectRelease(iter);
    return strings;
}

- (int)getDeviceVendorId:(io_service_t)device {
    return [self getUSBProperty:device propertyName:@"idVendor"];
}

- (int)getDeviceProductId:(io_service_t)device {
    return [self getUSBProperty:device propertyName:@"idProduct"];
}

- (NSString *)getDeviceSerialNumber:(io_service_t)device {
    IOUSBDeviceInterface182 **deviceInterface = [self getDeviceInterface:device];
    if (deviceInterface) {
        UInt8 index;
        (*deviceInterface)->USBGetSerialNumberStringIndex(deviceInterface, &index);
        NSString *result = [self getDeviceStringDescriptor:deviceInterface index:index];
        (*deviceInterface)->Release(deviceInterface);
        return result;
    }
    return nil;
}

- (NSString *)getDeviceManufacturer:(io_service_t)device {
    IOUSBDeviceInterface182 **deviceInterface = [self getDeviceInterface:device];
    if (deviceInterface) {
        UInt8 index;
        (*deviceInterface)->USBGetManufacturerStringIndex(deviceInterface, &index);
        NSString *result = [self getDeviceStringDescriptor:deviceInterface index:index];
        (*deviceInterface)->Release(deviceInterface);
        return result;
    }
    return nil;
}

/// MARK: -

- (int)getUSBProperty:(io_service_t)device propertyName:(NSString *)propertyName {
    CFNumberRef number = (CFNumberRef)IORegistryEntryCreateCFProperty(device, (__bridge CFStringRef)(propertyName), kCFAllocatorDefault, 0);
    
    if (number) {
        int value = 0;
        CFNumberGetValue(number, kCFNumberSInt32Type, &value);
        CFRelease(number);
        return value;
    }
    return -1;
}

- (IOUSBDeviceInterface182 **)getDeviceInterface:(io_service_t)device {
    kern_return_t result;
    SInt32 score;
    IOCFPlugInInterface **plugin = nil;
    result = IOCreatePlugInInterfaceForService(device, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugin, &score);
    if (result != KERN_SUCCESS) {
        return nil;
    }
    
    IOUSBDeviceInterface182 **deviceInterface = nil;
    result = (*plugin)->QueryInterface(plugin, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID182), (void **)&deviceInterface);
    if (result != KERN_SUCCESS) {
        IODestroyPlugInInterface(plugin);
        return nil;
    }
    IODestroyPlugInInterface(plugin);
    return deviceInterface;
}

- (NSString *)getDeviceStringDescriptor:(IOUSBDeviceInterface182 **)deviceInterface index:(uint8_t)index {
    UInt8 requestBuffer[256];
    IOUSBDevRequest request = {
        .bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice),
        .bRequest = kUSBRqGetDescriptor,
        .wValue = (kUSBStringDesc << 8) | index,
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

static int send_ctrl_msg(IOUSBDeviceInterface** dev, const UInt8 request, const UInt16 value, const UInt16 length)
{
    IOUSBDevRequest req;
    req.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBVendor, kUSBDevice);
    req.bRequest = request;
    req.wValue = value;
    req.wIndex = 0;
    req.wLength = length;
    req.pData = 0;
    req.wLenDone = 0;
    
    IOReturn rc = (*dev)->DeviceRequest(dev, &req);
    
    
    if(rc != kIOReturnSuccess)
    {
        return -1;
    }
    
    return req.wLenDone;
}
@end
