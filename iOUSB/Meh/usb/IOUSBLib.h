/*
 * Copyright (c) 1998-2000 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * The contents of this file constitute Original Code as defined in and
 * are subject to the Apple Public Source License Version 1.1 (the
 * "License").  You may not use this file except in compliance with the
 * License.  Please obtain a copy of the License at
 * http://www.apple.com/publicsource and read it before using this file.
 *
 * This Original Code and all software distributed under the License are
 * distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT.  Please see the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */
#ifndef _IOUSBLIB_H
#define _IOUSBLIB_H

#include <IOKit/usb/USB.h>
#include <IOKit/IOKitLib.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    // IOKit structures eequivalent to various descriptors
    typedef struct IOUSBConfiguration IOUSBConfiguration;
    typedef struct IOUSBInterface IOUSBInterface;
    typedef struct IOUSBEndpoint IOUSBEndpoint;
    typedef struct IOUSBDevice IOUSBDevice;
    
    struct IOUSBEndpoint {
        IOUSBEndpointDescriptor    *descriptor;
        IOUSBDevice            *device;
        IOUSBInterface         *interface;
        UInt8             number;
        UInt8            direction;    // in, out
        UInt8            transferType;    // cntrl, bulk, isoc, int
        UInt16            maxPacketSize;
        UInt8            interval;
    };
    
    struct IOUSBInterface {
        IOUSBInterfaceDescriptor    *descriptor;
        IOUSBDevice            *device;
        IOUSBConfiguration         *config;
        IOUSBEndpoint        **endpoints;
    };
    
    struct IOUSBConfiguration {
        IOUSBConfigurationDescriptor *descriptor;
        IOUSBDevice            *device;
        IOUSBInterface         **interfaces;
    };
    
    typedef struct {
        UInt8 theClass;        // requested class,    0 = don't care
        UInt8 subClass;        // requested subclass; 0 = don't care
        UInt8 protocol;        // requested protocol; 0 = don't care
        UInt8 busPowered:2;        // 1 = not bus powered, 2 = bus powered,
        // 0 = don't care
        UInt8 selfPowered:2;    // 1 = not self powered, 2 = self powered,
        // 0 = don't care
        UInt8 remoteWakeup:2;    // 1 = doesn't support remote wakeup; 2 = does
        // 0 = don't care
        UInt8 reserved:2;
        UInt8 maxPower;        // max power in 2ma increments; 0 = don't care
        UInt8 alternateIndex;    // alternate #; 0xff = find first only
        UInt8 configIndex;        // 0 = start at beginning
        UInt8 interfaceIndex;    // 0 = start at beginning
    } IOUSBFindInterfaceRequest;
    
    
    
    struct IOUSBUserPipe;    // Not same definition as Kernel IOUSBPipe.
    
    typedef struct IOUSBDeviceIterator * IOUSBIteratorRef;
    typedef IOUSBDevice * IOUSBDeviceRef;
    typedef struct IOUSBUserPipe * IOUSBPipeRef;
    
    IOReturn IOUSBCreateIterator(mach_port_t master_device_port, mach_port_t port,
                                 IOUSBMatch * descMatch, IOUSBIteratorRef * iter);
    IOReturn IOUSBIteratorNext(IOUSBIteratorRef iter);
    IOReturn IOUSBDisposeIterator(IOUSBIteratorRef iter);
    
    // Sets *isIntf to 1 if iter is an interface, 0 if it is a device.
    IOReturn IOUSBIsInterface(IOUSBIteratorRef iter, int *isIntf);
    
    IOReturn IOUSBGetDeviceDescriptor(IOUSBIteratorRef iter,
                                      IOUSBDeviceDescriptorPtr desc, UInt32 size);
    IOReturn IOUSBGetInterfaceDescriptor(IOUSBIteratorRef iter,
                                         IOUSBInterfaceDescriptorPtr desc, UInt32 size);
    
    
    IOReturn IOUSBNewDeviceRef(IOUSBIteratorRef iter, IOUSBDeviceRef *newDevice);
    IOReturn IOUSBDisposeRef(IOUSBDeviceRef object);
    
    // Device is in a really bad state - reset it
    // (as if it was unplugged then plugged in again)
    IOReturn IOUSBResetDevice(IOUSBDeviceRef object);
    
    IOReturn IOUSBGetConfigDescriptor(IOUSBDeviceRef device, UInt8 configIndex,
                                      IOUSBConfigurationDescriptorPtr *desc);
    
    
    IOReturn IOUSBSetConfiguration(IOUSBDeviceRef device, UInt8 config);
    IOReturn IOUSBGetConfiguration(IOUSBDeviceRef device, UInt8 *config);
    
    IOUSBInterface *IOUSBGetInterface(IOUSBDeviceRef device, UInt8 configIndex,
                                      UInt8 interfaceIndex, UInt8 alternateIndex);
    
    IOUSBInterface *IOUSBFindNextInterface(IOUSBDeviceRef device,
                                           IOUSBFindInterfaceRequest *request);
    
    void IOUSBDisposeInterface(IOUSBInterface * interface);
    
    IOReturn IOUSBOpenPipe(IOUSBDeviceRef device, IOUSBEndpoint * endpoint,
                           IOUSBPipeRef *pipe);
    
    IOReturn IOUSBClosePipe(IOUSBPipeRef pipe);
    
    IOReturn IOUSBReadPipe(IOUSBPipeRef pipe, void *buf, UInt32 *size);
    IOReturn IOUSBWritePipe(IOUSBPipeRef pipe, void *buf, UInt32 size);
    
    // Generic control request
    // wValue and wIndex are host-endian
    IOReturn IOUSBControlRequest(IOUSBPipeRef pipe, UInt8 bmreqtype,
                                 UInt8 request, UInt16 wValue, UInt16 wIndex, void *buf, UInt16 *size);
    
    // Controlling pipe state
    IOReturn IOUSBGetPipeStatus(IOUSBPipeRef pipe);
    IOReturn IOUSBAbortPipe(IOUSBPipeRef pipe);
    IOReturn IOUSBResetPipe(IOUSBPipeRef pipe);
    IOReturn IOUSBSetPipeIdle(IOUSBPipeRef pipe);
    IOReturn IOUSBSetPipeActive(IOUSBPipeRef pipe);
    IOReturn IOUSBClearPipeStall(IOUSBPipeRef pipe);
    
    UInt8 USBMakeBMRequestType(UInt8    rqDirection,
                               UInt8    rqType,
                               UInt8    rqRecipient);
    
    // Generic device request
    // wValue and wIndex are host-endian
    IOReturn IOUSBDeviceRequest(IOUSBDeviceRef device, UInt8 bmreqtype,
                                UInt8 request, UInt16 wValue, UInt16 wIndex, void *buf, UInt16 *size);
    
    
#ifdef __cplusplus
}
#endif

#endif /* ! _IOUSBLIB_H */
