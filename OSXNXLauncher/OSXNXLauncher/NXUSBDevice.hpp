//
//  NXUSBDevice.hpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#ifndef NXUSBDevice_hpp
#define NXUSBDevice_hpp

#ifdef USB_LIB_USB
#include "USBDevice.hpp"
#else
#include "USBDevice.hxx"
#endif

class NXUSBDevice
{
private:
    USBDevice* device;
    bool isDeviceReady;
    const std::uint16_t kNintendoSwitchVendorID = 0x0955;
    const std::uint16_t kNintendoSwitchProductID = 0x7321;
    
public:
    NXUSBDevice(USBDevice *device);
    ~NXUSBDevice();
    
    bool isNintendoSwitch();
    bool isDeviceOpen();
    bool read(std::vector<std::uint8_t> &data);
    bool write(std::vector<std::uint8_t> &data);
    bool control(std::vector<std::uint8_t> &data);
    
    /// Device Information
    std::string get_debug_info();
    
    /// Device Properties
    std::string get_manufacturer();
    std::string get_product_name();
    std::uint16_t get_vendor_id();
    std::uint16_t get_product_id();
    std::string get_device_id();
    
    /// USB Properties
    std::uint8_t get_descriptor_length();
    std::uint8_t get_descriptor_type();
    std::uint16_t get_specification_number();
    std::uint16_t get_device_release_number();
    std::uint8_t get_max_packet_size();
    std::uint8_t get_number_of_configurations();
};

#endif /* NXUSBDevice_hpp */
