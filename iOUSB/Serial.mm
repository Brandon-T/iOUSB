//
//  Serial.mm
//  iOUSB
//
//  Created by Brandon on 2018-05-21.
//  Copyright © 2018 XIO. All rights reserved.
//

#import "Serial.h"
#include <fstream>
#include <iostream>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

#define DEFAULT_BAUD_RATE 9600

@interface Serial()
@property (nonatomic, assign) int file_descriptor;
@property (nonatomic, strong) NSString *lastError;
@end

@implementation Serial
+ (instancetype)shared {
    static Serial *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Serial alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.file_descriptor = -1;
        self.lastError = nil;
    }
    return self;
}

- (void)dealloc {
    [self disconnect];
}

- (bool)setup:(NSString *)filePath {
    if (self.file_descriptor != -1)
    {
        return true;
    }
    
    self.file_descriptor = open(filePath.UTF8String, O_RDWR | O_NOCTTY | O_NDELAY | O_NONBLOCK);
    if (self.file_descriptor == -1)
    {
        const char* error = strerror(errno);
        self.lastError = [[NSString alloc] initWithUTF8String:error];
        perror(error);
        return false;
    }
    
    struct termios options;
    struct termios oldoptions;
    tcgetattr(self.file_descriptor, &oldoptions);
    options = oldoptions;
    
    #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
    int baud_rates[] = {B0, B50, B75, B110, B134, B150, B200, B300, B1200, B1800, B2400, B4800, B9600, B19200, B38400, B7200, B14400, B28800, B57600, B76800, B115200, B230400
    };
    #else
    int baud_rates[] = {B0, B50, B75, B110, B134, B150, B200, B300, B1200, B1800, B2400, B4800, B9600, B19200, B38400};
    #endif
    
    auto it = std::find(std::begin(baud_rates), std::end(baud_rates), BAUD_RATE);
    if (it != std::end(baud_rates))
    {
        cfsetispeed(&options, *it);
        cfsetospeed(&options, *it);
        std::cout<<"BAUD_RATE Set Successfully!\n";
    }
    else
    {
        cfsetispeed(&options, DEFAULT_BAUD_RATE);
        cfsetospeed(&options, DEFAULT_BAUD_RATE);
        std::cerr<<"Invalid BAUD_RATE.. Setting to default: "<<DEFAULT_BAUD_RATE<<"\n";
    }
    
    options.c_cflag |= (CLOCAL | CREAD);
    options.c_cflag |= CS8;
    options.c_cflag &= ~PARENB;
    options.c_cflag &= ~CSTOPB;
    options.c_cflag &= ~CSIZE;
    tcsetattr(self.file_descriptor, TCSANOW, &options);
    return true;
}

- (bool)disconnect {
    if (self.file_descriptor != -1)
    {
        close(self.file_descriptor);
        self.file_descriptor = -1;
        self.lastError = nil;
    }
    
    return self.file_descriptor == -1;
}

- (size_t)available {
    if (self.file_descriptor == -1)
    {
        return -1;
    }
    
    int available = -1;
    ioctl(self.file_descriptor, FIONREAD, &available);
    return available;
}

- (size_t)read:(uint8_t *)bytes length:(int32_t)length {
    if (self.file_descriptor == -1)
    {
        return -1;
    }
    
    ssize_t bytesRead = read(self.file_descriptor, bytes, length);
    if (bytesRead < 0)
    {
        const char* error = strerror(errno);
        self.lastError = [[NSString alloc] initWithUTF8String:error];
        perror(error);
    }
    return bytesRead;
}

- (size_t)write:(uint8_t *)bytes length:(int32_t)length {
    if (self.file_descriptor == -1)
    {
        return -1;
    }
    
    ssize_t bytesWritten = write(self.file_descriptor, bytes, length);
    if (bytesWritten <= 0)
    {
        const char* error = strerror(errno);
        self.lastError = [[NSString alloc] initWithUTF8String:error];
        perror(error);
    }
    return bytesWritten;
}

- (void)flushInputStream {
    if (self.file_descriptor == -1)
    {
        return;
    }
    
    tcflush(self.file_descriptor, TCIFLUSH);
}

- (void)flushOutputStream {
    if (self.file_descriptor == -1)
    {
        return;
    }
    
    tcflush(self.file_descriptor, TCOFLUSH);
}

- (void)flush {
    if (self.file_descriptor == -1)
    {
        return;
    }
    
    tcflush(self.file_descriptor, TCIOFLUSH);
}

- (NSString *)lastError {
    return _lastError ?: @"";
}

- (void)eraseLastError {
    _lastError = nil;
}
@end
