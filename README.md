# iOUSB

A project to upload payloads from iOS devices to a Nintendo Switch via the Serial Connector.

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