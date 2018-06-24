//
//  NXUSBDevice.cpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#include "NXUSBDevice.hpp"

NXUSBDevice::NXUSBDevice(USBDevice *device) : device(device), isDeviceReady(false)
{
    if (this->isNintendoSwitch())
    {
        if (device->open())
        {
            device->claim_interface(0);
            device->claim_interface(1);
            device->claim_interface(2);
            isDeviceReady = true;
        }
    }
}

NXUSBDevice::~NXUSBDevice()
{
    if (this->isNintendoSwitch())
    {
        device->unclaim_interface(0);
        device->close();
        isDeviceReady = false;
    }
}

bool NXUSBDevice::isNintendoSwitch()
{
    return device->get_vendor_id() == kNintendoSwitchVendorID && device->get_product_id() == kNintendoSwitchProductID;
}

bool NXUSBDevice::isDeviceOpen()
{
    return isDeviceReady;
}

bool NXUSBDevice::read(std::vector<std::uint8_t> &data)
{
    if (this->isNintendoSwitch() && this->isDeviceOpen())
    {
        #ifdef USB_LIB_USB
        return device->read(LIBUSB_ENDPOINT_IN | LIBUSB_REQUEST_TYPE_STANDARD | LIBUSB_RECIPIENT_INTERFACE, data);
        #else
        return device->read(kUSBIn | kUSBStandard | kUSBInterface, data);
        #endif
    }
    return false;
}

bool NXUSBDevice::write(std::vector<std::uint8_t> &data)
{
    if (this->isNintendoSwitch() && this->isDeviceOpen())
    {
        bool didWrite = true;
        int packetSize = 0x1000;
        std::uint8_t *ptr = &data[0];
        int length = static_cast<int>(data.size());
        
        while (length > 0)
        {
            std::int32_t amount  = std::min(packetSize, length);
            #ifdef USB_LIB_USB
            didWrite = device->write(LIBUSB_ENDPOINT_OUT | LIBUSB_RECIPIENT_INTERFACE, ptr, amount) && didWrite;
            #else
            didWrite = device->write(kUSBOut | kUSBInterface, ptr, amount) && didWrite;
            #endif
            ptr += amount;
            length -= amount;
        }
        
        return didWrite;
    }
    return false;
}

bool NXUSBDevice::control(std::vector<std::uint8_t> &data)
{
    if (this->isNintendoSwitch() && this->isDeviceOpen())
    {
        #ifdef USB_LIB_USB
        return device->control(LIBUSB_ENDPOINT_IN | LIBUSB_REQUEST_TYPE_STANDARD | LIBUSB_RECIPIENT_INTERFACE, LIBUSB_REQUEST_GET_STATUS, 0, 0, &data[0], static_cast<std::int32_t>(data.size()), 0);
        #else
        return device->control(kUSBIn | kUSBStandard | kUSBInterface, kUSBRqGetStatus, 0, 0, &data[0], static_cast<std::int32_t>(data.size()), 0);
        #endif
    }
    return false;
}

/// Device Information
std::string NXUSBDevice::get_debug_info()
{
    std::string info;
    info += "       Device Information\n";
    info += "-----------------------------------\n";
    info += string_format("Manufacturer: %s\n", this->get_manufacturer().c_str());
    info += string_format("Product Name: %s\n", this->get_product_name().c_str());
    info += string_format("VendorId: 0x%04X\n", this->get_vendor_id());
    info += string_format("ProductId: 0x%04X\n", this->get_product_id());
    info += string_format("DeviceId: %s\n", this->get_device_id().c_str());
    info += string_format("USB Specification Release Number: %d\n", this->get_specification_number());
    info += string_format("Device Release Number: %d\n", this->get_device_release_number());
    info += string_format("Max. Packet Size: %d\n", this->get_max_packet_size());
    return info;
}

/// Device Properties
std::string NXUSBDevice::get_manufacturer()
{
    return device->get_manufacturer();
}

std::string NXUSBDevice::get_product_name()
{
    return device->get_product_name();
}

std::uint16_t NXUSBDevice::get_vendor_id()
{
    return device->get_vendor_id();
}

std::uint16_t NXUSBDevice::get_product_id()
{
    return device->get_product_id();
}

std::string NXUSBDevice::get_device_id()
{
    auto uuid_to_string = [](const std::uint8_t* uuid) {
        std::string uuid_string(40, '\0');
        snprintf(&uuid_string[0], uuid_string.size(),
                 "{%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x}",
                 uuid[0], uuid[1], uuid[2], uuid[3], uuid[4], uuid[5], uuid[6], uuid[7],
                 uuid[8], uuid[9], uuid[10], uuid[11], uuid[12], uuid[13], uuid[14], uuid[15]);
        return uuid_string;
    };
    
    if (this->isNintendoSwitch() && this->isDeviceOpen())
    {
        std::vector<uint8_t> deviceId(16);
        read(deviceId);
        return uuid_to_string(&deviceId[0]);
    }
    
    return string_format("0x%04X", device->get_serial_number());
}

/// USB Properties
std::uint8_t NXUSBDevice::get_descriptor_length()
{
    return device->get_descriptor_length();
}

std::uint8_t NXUSBDevice::get_descriptor_type()
{
    return device->get_descriptor_type();
}

std::uint16_t NXUSBDevice::get_specification_number()
{
    return device->get_specification_number();
}

std::uint16_t NXUSBDevice::get_device_release_number()
{
    return device->get_device_release_number();
}

std::uint8_t NXUSBDevice::get_max_packet_size()
{
    return device->get_max_packet_size();
}

std::uint8_t NXUSBDevice::get_number_of_configurations()
{
    return device->get_number_of_configurations();
}
