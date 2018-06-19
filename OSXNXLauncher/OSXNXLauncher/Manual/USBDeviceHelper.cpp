//
//  USBDeviceHelper.cpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-06-03.
//  Copyright © 2018 XIO. All rights reserved.
//

#include "USBDeviceHelper.hpp"

#ifndef USB_LIB_USB

/// Converts IOKit errors to human readable strings.
std::string usb_human_error_string(IOReturn errorCode)
{
    //    #define err_get_system(err) (((err)>>26)&0x3f)
    //    #define err_get_sub(err) (((err)>>14)&0xfff)
    //    #define err_get_code(err) ((err)&0x3fff)
    
    switch (errorCode) {
        case kIOUSBUnknownPipeErr:
            return string_format("Pipe Ref Not Recognized (%08x)", errorCode);
            
        case kIOUSBTooManyPipesErr:
            return string_format("Too Many Pipes (%08x)", errorCode);
            
        case kIOUSBNoAsyncPortErr:
            return string_format("No Async Port (%08x)", errorCode);
            
        case kIOUSBNotEnoughPipesErr:
            return string_format("Not Enough Pipes in Interface (%08x)", errorCode);
            
        case kIOUSBNotEnoughPowerErr:
            return string_format("Not Enough Power for Selected Configuration (%08x)", errorCode);
            
        case kIOUSBEndpointNotFound:
            return string_format("Endpoint Not Found (%08x)", errorCode);
            
        case kIOUSBConfigNotFound:
            return string_format("Configuration Not Found (%08x)", errorCode);
            
        case kIOUSBTransactionTimeout:
            return string_format("Transaction Timed Out (%08x)", errorCode);
            
        case kIOUSBTransactionReturned:
            return string_format("Transaction has been returned to the caller (%08x)", errorCode);
            
        case kIOUSBPipeStalled:
            return string_format("Pipe has stalled, Error needs to be cleared (%08x)", errorCode);
            
        case kIOUSBInterfaceNotFound:
            return string_format("Interface Ref Not Recognized (%08x)", errorCode);
            
        case kIOUSBLowLatencyBufferNotPreviouslyAllocated:
            return string_format("Attempted to use user land low latency isoc calls w/out calling PrepareBuffer (on the data buffer) first (%08x)", errorCode);
            
        case kIOUSBLowLatencyFrameListNotPreviouslyAllocated:
            return string_format("Attempted to use user land low latency isoc calls w/out calling PrepareBuffer (on the frame list) first (%08x)", errorCode);
            
        case kIOUSBHighSpeedSplitError:
            return string_format("Error to hub on high speed bus trying to do split transaction (%08x)", errorCode);
            
        case kIOUSBSyncRequestOnWLThread:
            return string_format("A synchronous USB request was made on the workloop thread (from a callback?).  Only async requests are permitted in that case (%08x)", errorCode);
            
        case kIOUSBDeviceTransferredToCompanion:
            return string_format("The device has been tranferred to another controller for enumeration (%08x)", errorCode);
            
        case kIOUSBClearPipeStallNotRecursive:
            return string_format("ClearPipeStall should not be called recursively (%08x)", errorCode);
            
        case kIOUSBDevicePortWasNotSuspended:
            return string_format("Port was not suspended (%08x)", errorCode);
            
        case kIOUSBEndpointCountExceeded:
            return string_format("The endpoint was not created because the controller cannot support more endpoints (%08x)", errorCode);
            
        case kIOUSBDeviceCountExceeded:
            return string_format("The device cannot be enumerated because the controller cannot support more devices (%08x)", errorCode);
            
        case kIOUSBStreamsNotSupported:
            return string_format("The request cannot be completed because the XHCI controller does not support streams (%08x)", errorCode);
            
        case kIOUSBInvalidSSEndpoint:
            return string_format("An endpoint found in a SuperSpeed device is invalid (usually because there is no Endpoint Companion Descriptor) (%08x)", errorCode);
            
        case kIOUSBTooManyTransactionsPending:
            return string_format("The transaction cannot be submitted because it would exceed the allowed number of pending transactions (%08x)", errorCode);
            
        default:
            return string_format("Error Code (%08x)\n-- System: (%02X), SubSystem: (%02X), Code: (%02X) ", errorCode, err_get_system(errorCode), err_get_sub(errorCode), err_get_code(errorCode));
    }
}

std::string human_error_string(IOReturn errorCode)
{
    switch (errorCode) {
        case kIOReturnSuccess:
            return string_format("Success (%08x)", errorCode);
            
        case kIOReturnError:
            return string_format("General Error (%08x)", errorCode);
            
        case kIOReturnNoMemory:
            return string_format("Cannot Allocate Memory (%08x)", errorCode);
            
        case kIOReturnNoResources:
            return string_format("Resource Shortage (%08x)", errorCode);
            
        case kIOReturnIPCError:
            return string_format("IPC Error (%08x)", errorCode);
            
        case kIOReturnNoDevice:
            return string_format("No Such Device (%08x)", errorCode);
            
        case kIOReturnNotPrivileged:
            return string_format("Insufficient Privileges (%08x)", errorCode);
            
        case kIOReturnBadArgument:
            return string_format("Invalid Argument (%08x)", errorCode);
            
        case kIOReturnLockedRead:
            return string_format("Device Read Locked (%08x)", errorCode);
            
        case kIOReturnLockedWrite:
            return string_format("Device Write Locked (%08x)", errorCode);
            
        case kIOReturnExclusiveAccess:
            return string_format("Exclusive Access and Device already opened (%08x)", errorCode);
            
        case kIOReturnBadMessageID:
            return string_format("Sent/Received Messages had different MSG_ID (%08x)", errorCode);
            
        case kIOReturnUnsupported:
            return string_format("Unsupported Function (%08x)", errorCode);
            
        case kIOReturnVMError:
            return string_format("Misc. VM Failure (%08x)", errorCode);
            
        case kIOReturnInternalError:
            return string_format("Internal Error (%08x)", errorCode);
            
        case kIOReturnIOError:
            return string_format("General I/O Error (%08x)", errorCode);
            
        case kIOReturnCannotLock:
            return string_format("Can't Acquire Lock (%08x)", errorCode);
            
        case kIOReturnNotOpen:
            return string_format("Device Not Open (%08x)", errorCode);
            
        case kIOReturnNotReadable:
            return string_format("Read Not Supported (%08x)", errorCode);
            
        case kIOReturnNotWritable:
            return string_format("Write Not Supported (%08x)", errorCode);
            
        case kIOReturnNotAligned:
            return string_format("Alignment Error (%08x)", errorCode);
            
        case kIOReturnBadMedia:
            return string_format("Media Error (%08x)", errorCode);
            
        case kIOReturnStillOpen:
            return string_format("Device(s) Still Open (%08x)", errorCode);
            
        case kIOReturnRLDError:
            return string_format("RLD Failure (%08x)", errorCode);
            
        case kIOReturnDMAError:
            return string_format("DMA Failure (%08x)", errorCode);
            
        case kIOReturnBusy:
            return string_format("Device Busy (%08x)", errorCode);
            
        case kIOReturnTimeout:
            return string_format("I/O Timeout (%08x)", errorCode);
            
        case kIOReturnOffline:
            return string_format("Device Offline (%08x)", errorCode);
            
        case kIOReturnNotReady:
            return string_format("Not Ready (%08x)", errorCode);
            
        case kIOReturnNotAttached:
            return string_format("Device Not Attached (%08x)", errorCode);
            
        case kIOReturnNoChannels:
            return string_format("No DMA Channels Left (%08x)", errorCode);
            
        case kIOReturnNoSpace:
            return string_format("No Space For Data (%08x)", errorCode);
            
        case kIOReturnPortExists:
            return string_format("Port Already Exists (%08x)", errorCode);
            
        case kIOReturnCannotWire:
            return string_format("Can't Write Down (%08x)", errorCode);
            
        case kIOReturnNoInterrupt:
            return string_format("No Interrupt Attached (%08x)", errorCode);
            
        case kIOReturnNoFrames:
            return string_format("No DMA Frames Enqueued (%08x)", errorCode);
            
        case kIOReturnMessageTooLarge:
            return string_format("Oversized MSG Received On Interrupt Port (%08x)", errorCode);
            
        case kIOReturnNotPermitted:
            return string_format("Not Permitted (%08x)", errorCode);
            
        case kIOReturnNoPower:
            return string_format("No Power To Device (%08x)", errorCode);
            
        case kIOReturnNoMedia:
            return string_format("Media Not Present (%08x)", errorCode);
            
        case kIOReturnUnformattedMedia:
            return string_format("Media Not Formatted (%08x)", errorCode);
            
        case kIOReturnUnsupportedMode:
            return string_format("No Such Mode (%08x)", errorCode);
            
        case kIOReturnUnderrun:
            return string_format("Buffer Underflow (%08x)", errorCode);
            
        case kIOReturnOverrun:
            return string_format("Buffer Overflow (%08x)", errorCode);
            
        case kIOReturnDeviceError:
            return string_format("The Device Is Not Working Properly! (%08x)", errorCode);
            
        case kIOReturnNoCompletion:
            return string_format("A Completion Routine Is Required (%08x)", errorCode);
            
        case kIOReturnAborted:
            return string_format("Operation Aborted (%08x)", errorCode);
            
        case kIOReturnNoBandwidth:
            return string_format("Bus Bandwidth Would Be Exceeded (%08x)", errorCode);
            
        case kIOReturnNotResponding:
            return string_format("Device Not Responding (%08x)", errorCode);
            
        case kIOReturnIsoTooOld:
            return string_format("ISOChronous I/O request for distance past! (%08x)", errorCode);
            
        case kIOReturnIsoTooNew:
            return string_format("ISOChronous I/O request for distant future! (%08x)", errorCode);
            
        case kIOReturnNotFound:
            return string_format("Data Not Found (%08x)", errorCode);
            
        case kIOReturnInvalid:
            return string_format("Should Never Be Seen(%08x)", errorCode);
            
        default:
            /// See here for more: https://developer.apple.com/library/content/qa/qa1075/_index.html
            return usb_human_error_string(errorCode);
    }
}

/// INTERNAL

IOReturn GetDeviceDescriptor(IOUSBDeviceInterface300** device, UInt16 desc, UInt16 index, IOUSBDeviceDescriptor &descriptor)
{
    memset(&descriptor, 0, sizeof(IOUSBDeviceDescriptor));
    
    IOUSBDevRequestTO request = {
        .bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice),
        .bRequest      = kUSBRqGetDescriptor,
        .wValue        = static_cast<UInt16>(desc << 8),
        .wIndex        = index,
        .wLength       = sizeof(IOUSBDeviceDescriptor),
        .pData         = &descriptor,
        .noDataTimeout = 20,
        .completionTimeout = 100
    };
    
    return (*device)->DeviceRequestTO (device, &request);
}

/// PUBLIC

IOReturn GetDeviceDescriptor(IOUSBDeviceInterface300** device, IOUSBDeviceDescriptor &descriptor)
{
    bool is_open = ((*device)->USBDeviceOpenSeize(device) == kIOReturnSuccess);
    IOReturn kr = GetDeviceDescriptor(device, kUSBDeviceDesc, 0, descriptor);
    if (is_open)
    {
        (*device)->USBDeviceClose(device);
    }
    return kr;
}

std::int32_t GetDeviceConfigurationIndex(IOUSBDeviceInterface300** device, UInt8 bConfigurationValue, IOUSBConfigurationDescriptorPtr &descriptor)
{
    UInt8 numConfig = 0;
    IOReturn kr = (*device)->GetNumberOfConfigurations(device, &numConfig);
    if (kr != kIOReturnSuccess)
    {
        return -1;
    }
    
    for (UInt8 i = 0; i < numConfig; ++i)
    {
        (*device)->GetConfigurationDescriptorPtr(device, i, &descriptor);
        if (descriptor->bConfigurationValue == bConfigurationValue)
        {
            return i;
        }
    }
    
    return -1;
}

IOUSBDeviceInterface300** GetDeviceInterface(io_object_t device)
{
    /// Create a plugin interface for the service.
    IOCFPlugInInterface **plugInInterface = nullptr;
    SInt32 score = 0;
    
    kern_return_t kr = IOCreatePlugInInterfaceForService(device, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
    
    if ((kIOReturnSuccess != kr) || !plugInInterface)
    {
        return nullptr;
    }
    
    /// Get an interface from the plugin.. and release the plugin
    void **interface = nullptr;
    HRESULT res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (LPVOID*) &interface);
    (*plugInInterface)->Release(plugInInterface);
    
    if (res || !interface)
    {
        return nullptr;
    }
    return reinterpret_cast<IOUSBDeviceInterface300 **>(interface);
}

IOUSBInterfaceInterface300** GetDeviceUSBInterface(io_object_t device)
{
    /// Create a plugin interface for the service.
    IOCFPlugInInterface **plugInInterface = nullptr;
    SInt32 score = 0;
    
    kern_return_t kr = IOCreatePlugInInterfaceForService(device, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
    
    if ((kIOReturnSuccess != kr) || !plugInInterface)
    {
        return nullptr;
    }
    
    /// Get an interface from the plugin.. and release the plugin
    void **interface = nullptr;
    HRESULT res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID300), (LPVOID*) &interface);
    (*plugInInterface)->Release(plugInInterface);
    
    if (res || !interface)
    {
        return nullptr;
    }
    return reinterpret_cast<IOUSBInterfaceInterface300 **>(interface);
}

io_object_t GetInterface(IOUSBDeviceInterface300** device, UInt8 ifc)
{
    io_iterator_t itr;
    
    IOUSBFindInterfaceRequest request;
    request.bInterfaceClass    = kIOUSBFindInterfaceDontCare;
    request.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
    request.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
    request.bAlternateSetting  = kIOUSBFindInterfaceDontCare;
    
    kern_return_t kr = (*device)->CreateInterfaceIterator(device, &request, &itr);
    if (kr != kIOReturnSuccess)
    {
        return IO_OBJECT_NULL;
    }
    
    io_object_t usbInterface;
    while ((usbInterface = IOIteratorNext(itr)))
    {
        UInt8 bInterfaceNumber = GetProperty(usbInterface, "bInterfaceNumber");
        
        if (bInterfaceNumber >= 0 && bInterfaceNumber == ifc)
        {
            break;
        }
        
        IOObjectRelease(usbInterface);
    }
    IOObjectRelease(itr);
    return usbInterface;
}

int GetProperty(io_object_t device, std::string propertyName)
{
    CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, propertyName.c_str(), kCFStringEncodingUTF8);
    CFNumberRef number = (CFNumberRef)IORegistryEntryCreateCFProperty(device, name, kCFAllocatorDefault, 0);
    
    if (number)
    {
        int value = 0;
        CFNumberGetValue(number, kCFNumberSInt32Type, &value);
        CFRelease(number);
        CFRelease(name);
        return value;
    }
    
    CFRelease(name);
    return -1;
}

std::string GetDeviceStringDescriptor(IOUSBDeviceInterface300** deviceInterface, std::uint8_t index)
{
    std::uint8_t requestBuffer[256];
    IOUSBDevRequest request = {
        .bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice),
        .bRequest = kUSBRqGetDescriptor,
        .wValue = static_cast<std::uint16_t>((kUSBStringDesc << 8) | index),
        .wIndex = 0x409, //English
        .wLength = sizeof(requestBuffer),
        .pData = requestBuffer
    };
    
    kern_return_t kr = (*deviceInterface)->DeviceRequest(deviceInterface, &request);
    if (kr != KERN_SUCCESS)
    {
        return "";
    }
    
    CFStringRef descriptor = CFStringCreateWithBytes(kCFAllocatorDefault, &requestBuffer[2], requestBuffer[0] - 2, kCFStringEncodingUTF16LE, false);
    
    CFIndex length = CFStringGetLength(descriptor);
    CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    std::string result(maxSize, '\0');
    CFStringGetCString(descriptor, &result[0], maxSize, kCFStringEncodingUTF8);
    CFRelease(descriptor);
    return result;
}

bool GetEndpoints(IOUSBInterfaceInterface300** interface, UInt8 &controlPipeRef, UInt8 &readPipeRef, UInt8 &writePipeRef)
{
    controlPipeRef = 0x00;
    readPipeRef = 0x01;
    writePipeRef = 0x02;
    
    if (interface)
    {
        UInt8 interfaceNumEndpoints = 0;
        IOReturn err = (*interface)->GetNumEndpoints(interface, &interfaceNumEndpoints);
        if (err)
        {
            return false;
        }
        
        for (UInt8 ref = 1; ref <= interfaceNumEndpoints; ++ref)
        {
            UInt8 direction;
            UInt8 number;
            UInt8 transferType;
            UInt16 maxPacketSize;
            UInt8 interval;
            
            IOReturn kr = (*interface)->GetPipeProperties(interface, ref, &direction, &number, &transferType, &maxPacketSize, &interval);
            
            if (kr != kIOReturnSuccess)
            {
                return false;
            }
            
            if (transferType == kUSBControl)
            {
                controlPipeRef = 0;
            }
            else if (transferType == kUSBBulk)
            {
                if (direction == kUSBIn)
                {
                    readPipeRef = ref;
                }
                else if (direction == kUSBOut)
                {
                    writePipeRef = ref;
                }
            }
        }
    }
    return true;
}

bool BulkTransfer(IOUSBInterfaceInterface300** interface, UInt8 pipeRef, std::uint8_t* buffer, std::uint32_t* size)
{
    return (*interface)->ReadPipe(interface, pipeRef, buffer, size) == kIOReturnSuccess;
}
#endif
