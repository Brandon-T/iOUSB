//
//  USBDevice.cpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#include "USBDevice.hpp"
#ifdef USB_LIB_USB

/// Device

USBDevice::USBDevice(libusb_device* device) : device(device), desc(), handle(nullptr)
{
    libusb_get_device_descriptor(device, &desc);
}

USBDevice::~USBDevice()
{
    close();
}

bool USBDevice::open()
{
    return !libusb_open(device, &handle);
}

void USBDevice::close()
{
    libusb_close(handle);
    handle = nullptr;
}

bool USBDevice::claim_interface(std::int32_t interface)
{
    int config = 0;
    libusb_get_configuration(handle, &config);
    libusb_set_configuration(handle, 1);
    
    return !libusb_claim_interface(handle, interface);
}

bool USBDevice::unclaim_interface(std::int32_t interface)
{
    return !libusb_release_interface(handle, interface);
}

bool USBDevice::write(std::uint8_t endpoint, std::vector<uint8_t> &data)
{
    return write(endpoint, &data[0], data.size());
}

bool USBDevice::write(std::uint8_t endpoint, std::uint8_t* data, std::size_t size)
{
    std::int32_t received = 0;
    int kr = libusb_bulk_transfer(handle, endpoint, &data[0], static_cast<std::int32_t>(size), &received, 0);
    switch (kr) {
        case LIBUSB_ERROR_TIMEOUT:
        case LIBUSB_ERROR_PIPE:
        case LIBUSB_ERROR_OVERFLOW:
        case LIBUSB_ERROR_NO_DEVICE:
        case LIBUSB_ERROR_BUSY:
            return false;
    }
    
    return received == size;
}

bool USBDevice::read(std::uint8_t endpoint, std::vector<uint8_t> &data)
{
    return read(endpoint, &data[0], data.size());
}

bool USBDevice::read(std::uint8_t endpoint, std::uint8_t* data, std::size_t size)
{
    std::int32_t received = 0;
    libusb_bulk_transfer(handle, endpoint, &data[0], static_cast<std::int32_t>(size), &received, 0);
    return received == size;
}

bool USBDevice::control(std::uint8_t bmRequest, std::uint8_t bRequest, std::uint16_t wValue, std::uint16_t wIndex, std::uint8_t* data, std::uint16_t wLength, std::uint32_t timeout)
{
    int kr = libusb_control_transfer(handle, bmRequest, bRequest, wValue, wIndex, &data[0], wLength, timeout);
    switch (kr) {
        case LIBUSB_ERROR_TIMEOUT:
        case LIBUSB_ERROR_PIPE:
        case LIBUSB_ERROR_OVERFLOW:
        case LIBUSB_ERROR_NO_DEVICE:
        case LIBUSB_ERROR_BUSY:
            return false;
    }
    
    return kr == wLength;
}

/// Properties
std::string USBDevice::get_manufacturer()
{
    if (handle)
    {
        char manufacturer[256] = {0};
        libusb_get_string_descriptor_ascii(handle, desc.iManufacturer, reinterpret_cast<std::uint8_t*>(&manufacturer[0]), sizeof(manufacturer));
        return manufacturer;
    }
    return "";
}

std::string USBDevice::get_product_name()
{
    if (handle)
    {
        char productName[256] = {0};
        libusb_get_string_descriptor_ascii(handle, desc.iProduct, reinterpret_cast<std::uint8_t*>(&productName[0]), sizeof(productName));
        return productName;
    }
    return "";
}

std::uint16_t USBDevice::get_vendor_id()
{
    return desc.idVendor;
}

std::uint16_t USBDevice::get_product_id()
{
    return desc.idProduct;
}

std::uint8_t USBDevice::get_serial_number()
{
    return desc.iSerialNumber;
}

/// USB Properties
std::uint8_t USBDevice::get_descriptor_length()
{
    return desc.bLength;
}

std::uint8_t USBDevice::get_descriptor_type()
{
    return desc.bDescriptorType;
}

std::uint16_t USBDevice::get_specification_number()
{
    return desc.bcdUSB;
}

std::uint16_t USBDevice::get_device_release_number()
{
    return desc.bcdDevice;
}

std::uint8_t USBDevice::get_max_packet_size()
{
    return desc.bMaxPacketSize0;
}

std::uint8_t USBDevice::get_number_of_configurations()
{
    return desc.bNumConfigurations;
}


/// Device Manager

USBDeviceManager::USBDeviceManager() : context(nullptr), deviceList(nullptr), deviceCount(0)
{
    int rc = libusb_init(&context);
    if (rc)
    {
        throw std::runtime_error("Initialize USBDeviceManager");
    }
    
    libusb_set_option(context, LIBUSB_OPTION_LOG_LEVEL, LIBUSB_LOG_LEVEL_DEBUG);
}

USBDeviceManager::~USBDeviceManager()
{
    if (deviceList)
    {
        libusb_free_device_list(deviceList, 1);
        deviceList = nullptr;
    }
    
    if (context)
    {
        libusb_exit(context);
        context = nullptr;
    }
}

std::vector<std::unique_ptr<USBDevice>> USBDeviceManager::list_devices()
{
    std::vector<std::unique_ptr<USBDevice>> devices = {};
    
    if (deviceList)
    {
        libusb_free_device_list(deviceList, 1);
        deviceList = nullptr;
    }
    
    std::size_t deviceCount = libusb_get_device_list(context, &deviceList);
    if (deviceCount <= 0)
    {
        return devices;
    }
    
    for (ssize_t i = 0; i < deviceCount; ++i)
    {
        if (deviceList[i])
        {
            devices.push_back(std::unique_ptr<USBDevice>(new USBDevice(deviceList[i])));
        }
    }
    
    return devices;
}
#endif
