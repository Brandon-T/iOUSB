//
//  USBDevice.h
//  iOUSB
//
//  Created by Brandon on 2018-05-28.
//  Copyright © 2018 XIO. All rights reserved.
//

#ifndef USB_LIB_USB
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
#include "USBDeviceHelper.hpp"


/// Devices
class USBDevice
{
private:
    IOUSBDeviceDescriptor desc;
    IOUSBDeviceInterface300** deviceInterface;
    io_object_t device;
    std::array<IOUSBInterfaceInterface300**, 32> interfaces;
    std::uint8_t controlPipe;
    std::uint8_t readPipe;
    std::uint8_t writePipe;
    
    
    
public:
    USBDevice(io_object_t device);
    ~USBDevice();
    
    bool open();
    
    void close();
    
    bool claim_interface(std::uint8_t interface);
    
    bool unclaim_interface(std::uint8_t interface);
    
    bool write(std::uint8_t endpoint, std::vector<uint8_t> &data);
    
    bool write(std::uint8_t endpoint, std::uint8_t* data, std::size_t size);
    
    bool read(std::uint8_t endpoint, std::vector<uint8_t> &data);
    
    bool read(std::uint8_t endpoint, std::uint8_t* data, std::size_t size);
    
    bool control(std::uint8_t bmRequest, std::uint8_t bRequest, std::uint16_t wValue, std::uint16_t wIndex, std::uint8_t* data, std::uint16_t wLength, std::uint32_t timeout);
    
    
    /// Properties
    std::string get_manufacturer();
    std::string get_product_name();
    std::uint16_t get_vendor_id();
    std::uint16_t get_product_id();
    std::uint8_t get_serial_number();
    
    /// USB Properties
    std::uint8_t get_descriptor_length();
    std::uint8_t get_descriptor_type();
    std::uint16_t get_specification_number();
    std::uint16_t get_device_release_number();
    std::uint8_t get_max_packet_size();
    std::uint8_t get_number_of_configurations();
};

/// Device Manager
class USBDeviceManager
{
public:
    USBDeviceManager();
    ~USBDeviceManager();
    
    std::vector<std::unique_ptr<USBDevice>> GetDevicesMatching(std::string service, int vendorId, int productId);
};
#endif
