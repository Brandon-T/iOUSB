//
//  USBDevice.m
//  iOUSB
//
//  Created by Brandon on 2018-05-28.
//  Copyright © 2018 XIO. All rights reserved.
//

#include "USBDevice.hxx"

#ifndef USB_LIB_USB
#define COMMRELEASE(ptr) if (ptr) (*ptr)->Release(ptr)


#pragma mark - Device Private
USBDevice::USBDevice(io_object_t device) : deviceInterface(nullptr), device(device)
{
    IOObjectRetain(device);
    
    deviceInterface = GetDeviceInterface(device);
    
    if (deviceInterface)
    {
        GetDeviceDescriptor(deviceInterface, this->desc);
    }
}

USBDevice::~USBDevice()
{
    COMMRELEASE(deviceInterface);
    
    close();
    IOObjectRelease(device);
}

bool USBDevice::open()
{
    if (deviceInterface)
    {
        IOReturn kr = (*deviceInterface)->USBDeviceOpenSeize(deviceInterface);
        if (kr != kIOReturnSuccess)
        {
            if (kr != kIOReturnExclusiveAccess)
            {
                return false;
            }
        }
        return true;
    }
    return false;
}

void USBDevice::close()
{
    if (deviceInterface)
    {
        (*deviceInterface)->USBDeviceClose(deviceInterface);
    }
}

bool USBDevice::claim_interface(std::uint8_t interface)
{
    io_object_t usbDevice = GetInterface(deviceInterface, interface);
    if (!usbDevice)
    {
        return false;
    }
    
    unclaim_interface(interface);

    IOUSBInterfaceInterface300** usbInterface = GetDeviceUSBInterface(usbDevice);
    kern_return_t kr = (*usbInterface)->USBInterfaceOpen(usbInterface);
    if (kr != kIOReturnSuccess)
    {
        (*usbInterface)->Release(usbInterface);
    }
    
    GetEndpoints(usbInterface, controlPipe, readPipe, writePipe);
    
    interfaces[interface] = usbInterface;
    return true;
}

bool USBDevice::unclaim_interface(std::uint8_t interface)
{
    if (interfaces[interface])
    {
        (*interfaces[interface])->USBInterfaceClose(*interfaces[interface]);
        (*interfaces[interface])->Release(interfaces[interface]);
        interfaces[interface] = nullptr;
    }
    
    return true;
}

bool USBDevice::write(std::uint8_t endpoint, std::vector<uint8_t> &data)
{
    return write(endpoint, &data[0], data.size());
}

bool USBDevice::write(std::uint8_t endpoint, std::uint8_t* data, std::size_t size)
{
    return (*interfaces[0])->WritePipe(interfaces[0], writePipe, data, (std::uint32_t)size) == kIOReturnSuccess;
}

bool USBDevice::read(std::uint8_t endpoint, std::vector<uint8_t> &data)
{
    return read(endpoint, &data[0], data.size());
}

bool USBDevice::read(std::uint8_t endpoint, std::uint8_t* data, std::size_t size)
{
    return (*interfaces[0])->ReadPipe(interfaces[0], readPipe, data, (std::uint32_t *)&size) == kIOReturnSuccess;
}

bool USBDevice::control(std::uint8_t bmRequest, std::uint8_t bRequest, std::uint16_t wValue, std::uint16_t wIndex, std::uint8_t* data, std::uint16_t wLength, std::uint32_t timeout)
{
    IOUSBDevRequest req;
    req.bmRequestType = bmRequest;
    req.bRequest = bRequest;
    req.wValue = OSSwapLittleToHostInt16(wValue);
    req.wIndex = OSSwapLittleToHostInt16(wIndex);
    req.wLength = OSSwapLittleToHostInt16(wLength);
    req.pData = data;
    
    kern_return_t result = (*interfaces[0])->ControlRequest(interfaces[0], readPipe, &req);
    return result != kIOReturnSuccess ? -1 : req.wLenDone; //Bytes Transferred..
}


/// Properties
std::string USBDevice::get_manufacturer()
{
    return GetDeviceStringDescriptor(deviceInterface, desc.iManufacturer);
}

std::string USBDevice::get_product_name()
{
    return GetDeviceStringDescriptor(deviceInterface, desc.iProduct);
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

#pragma mark - USB Public

USBDeviceManager::USBDeviceManager()
{
}

USBDeviceManager::~USBDeviceManager()
{
    
}

std::vector<std::unique_ptr<USBDevice>> USBDeviceManager::GetDevicesMatching(std::string service, int vendorId, int productId)
{
    io_iterator_t iter = 0;
    
    /// Find Matching Services
    CFMutableDictionaryRef matchingDict = IOServiceMatching(service.c_str());
    if (matchingDict == nil)
    {
        return std::vector<std::unique_ptr<USBDevice>> {};
    }
    
    /// Added VendorID and ProductID to query
    if (vendorId && productId)
    {
        CFNumberRef numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &vendorId);
        CFDictionarySetValue(matchingDict, CFSTR(kUSBVendorID), numberRef);
        CFRelease(numberRef);
        
        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &productId);
        CFDictionarySetValue(matchingDict, CFSTR(kUSBProductID), numberRef);
        CFRelease(numberRef);
        numberRef = nullptr;
    }
    
    /// Find devices matching the above criteria
    kern_return_t kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
    if (kr != KERN_SUCCESS)
    {
        std::cerr<<human_error_string(kr)<<"\n";
        return std::vector<std::unique_ptr<USBDevice>> {};
    }
    
    /// Iterate over all devices
    io_service_t device = 0;
    std::vector<std::unique_ptr<USBDevice>> devices;
    while ((device = IOIteratorNext(iter)))
    {
        devices.push_back(std::unique_ptr<USBDevice>(new USBDevice(device)));
    }
    
    IOObjectRelease(iter);
    return devices;
}
#endif
