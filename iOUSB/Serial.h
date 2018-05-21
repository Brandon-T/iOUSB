//
//  Serial.h
//  iOUSB
//
//  Created by Brandon on 2018-05-21.
//  Copyright © 2018 XIO. All rights reserved.
//

#if !defined(__cplusplus)  //-fmodules -fcxx-modules
@import Foundation;
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wauto-import"
#import <Foundation/Foundation.h>
#pragma clang diagnostic pop
#endif

#define BAUD_RATE 9600

@interface Serial : NSObject
+ (instancetype)shared;
- (bool)setup:(NSString *)filePath;
- (bool)disconnect;
- (size_t)available;
- (size_t)read:(uint8_t *)bytes length:(int32_t)length;
- (size_t)write:(uint8_t *)bytes length:(int32_t)length;
- (void)flushInputStream;
- (void)flushOutputStream;
- (void)flush;
- (NSString *)lastError;
- (void)eraseLastError;
@end
