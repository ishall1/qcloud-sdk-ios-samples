#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TACCrash.h"
#import "TACCrashContants.h"
#import "TACCrashOptions.h"
#import "TACCrashService.h"
#import "TACCrashServiceDelegate.h"
#import "TACCrashVersion.h"

FOUNDATION_EXPORT double TACCrashVersionNumber;
FOUNDATION_EXPORT const unsigned char TACCrashVersionString[];

