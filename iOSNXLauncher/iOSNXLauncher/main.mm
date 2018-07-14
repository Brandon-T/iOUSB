//
//  main.cpp
//  iOSNXLauncher
//
//  Created by Brandon on 2018-07-10.
//  Copyright © 2018 XIO. All rights reserved.
//

#include "main.h"
#include <stdio.h>
#include <dlfcn.h>
#include <unistd.h>

#import <UIKit/UIKit.h>
#import <iOSNXLauncher-Swift.h>

void patch_setuid() {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle)
        return;
    
    // Reset errors
    dlerror();
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error)
        return;
    
    ptr(getpid());
}

void platformize_me() {
    #define FLAG_PLATFORMIZE (1 << 1)
    
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle) return;
    
    // Reset errors
    dlerror();
    typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
    fix_entitle_prt_t ptr = (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error) return;
    
    ptr(getpid(), FLAG_PLATFORMIZE);
}

int main(int argc, char* argv[]) {
    @autoreleasepool {
        platformize_me();
        patch_setuid();
        setuid(0);
        setgid(0);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
