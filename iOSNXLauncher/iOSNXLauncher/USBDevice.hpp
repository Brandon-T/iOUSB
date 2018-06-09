//
//  USBDevice.hpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#ifndef USBDevice_hpp
#define USBDevice_hpp

#include <vector>
#include <string>
#include <libusb/libusb.h>

#ifdef USB_LIB_USB
template<typename... Args>
std::string string_format(const std::string& format, Args... args)
{
    size_t size = std::snprintf(nullptr, 0, format.c_str(), args...) + 1;
    std::unique_ptr<char[]> buf(new char[size]);
    std::snprintf(buf.get(), size, format.c_str(), args...);
    return std::string(buf.get(), buf.get() + size - 1);
}


class USBDevice
{
private:
    libusb_device* device;
    libusb_device_descriptor desc;
    libusb_device_handle* handle;
    
public:
    USBDevice(libusb_device* device);
    
    ~USBDevice();
    
    bool open();
    
    void close();
    
    bool claim_interface(std::int32_t interface);
    
    bool unclaim_interface(std::int32_t interface);
    
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


class USBDeviceManager
{
private:
    libusb_context* context;
    libusb_device** deviceList;
    ssize_t deviceCount;
    
public:
    USBDeviceManager();
    ~USBDeviceManager();
    
    std::vector<std::unique_ptr<USBDevice>> list_devices();
};
#endif

#endif /* USBDevice_hpp */
