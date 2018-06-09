# iOUSB

A project to upload payloads from iOS devices to a Nintendo Switch via the Serial Connector/OTG-Adapter.

# To Compile, Run the following commands:

IOKit installation
```sudo cp -r /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/IOKit.framework```

and

OSTypes installation
```sudo cp /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/libkern/OSTypes.h /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include/libkern```


64-bit Only System, Change OSTypes.h (IE: Building only for iOS11+ -- Do not do this if building for multiple OS versions):

```
#if __LP64__
typedef unsigned int UInt32;
#else
typedef unsigned long UInt32;
#endif


#if __LP64__
typedef signed int SInt32;
#else
typedef signed long SInt32;
#endif
```


# Dependencies:
LibUSB: https://github.com/libusb/libusb

I've already included a modified version of `libusb` project file to compile for iOS. The above link is here just in case you'd like to do everything yourself.

In that case, you need to change: 

`BuildSettings -> Base-SDK` to `Latest iOS (iOS ##.#)`.
`BuildSettings -> SkipInstall` to `YES`.

If you need to `archive` an ipa for distribution, then you need to modify the `OSTypes.h` as described above in order to build with bit-code and 64-bit devices.
