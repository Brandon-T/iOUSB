//
//  USBDeviceHelper.hpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#ifndef USBDeviceHelper_hpp
#define USBDeviceHelper_hpp

extern "C" {
    #import <IOKit/IOKitLib.h>
    #import <IOKit/usb/IOUSBLib.h>
    #import <IOKit/IOCFPlugIn.h>
    #import <IOKit/IOMessage.h>
    #import <IOKit/IOBSD.h>
    #import <CoreFoundation/CoreFoundation.h>
}

#include <memory>
#include <string>

#define USBSAFERELEASE(ref) if (ref) CFRelease(ref)

/// Allow formatting of C++ strings
template<typename... Args>
std::string string_format(const std::string& format, Args... args)
{
    size_t size = std::snprintf(nullptr, 0, format.c_str(), args...) + 1;
    std::unique_ptr<char[]> buf(new char[size]);
    std::snprintf(buf.get(), size, format.c_str(), args...);
    return std::string(buf.get(), buf.get() + size - 1);
}

/// Converts IOKit errors to human readable strings.
std::string human_error_string(IOReturn errorCode);






/// Device Descriptor
IOReturn GetDeviceDescriptor(IOUSBDeviceInterface300** device, IOUSBDeviceDescriptor &descriptor);

/// Device Interface
IOUSBDeviceInterface300** GetDeviceInterface(io_object_t device);

/// Device USB Interface
IOUSBInterfaceInterface300** GetDeviceUSBInterface(io_object_t device);

io_object_t GetInterface(IOUSBDeviceInterface300** device, UInt8 ifc);

int GetProperty(io_object_t device, std::string propertyName);

std::string GetDeviceStringDescriptor(IOUSBDeviceInterface300** deviceInterface, std::uint8_t index);

bool GetEndpoints(IOUSBInterfaceInterface300** interface, UInt8 &controlPipeRef, UInt8 &readPipeRef, UInt8 &writePipeRef);

bool BulkTransfer(IOUSBInterfaceInterface300** interface, UInt8 pipeRef, std::uint8_t* buffer, std::uint32_t* size);

#endif /* USBDeviceHelper_hpp */
