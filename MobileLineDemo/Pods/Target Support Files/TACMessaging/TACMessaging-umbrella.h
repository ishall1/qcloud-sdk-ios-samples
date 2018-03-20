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

#import "TACMessaging.h"
#import "TACMessagingApplicationDelegateInjection.h"
#import "TACMessagingContants.h"
#import "TACMessagingDelegate.h"
#import "TACMessagingDeviceToken+Private.h"
#import "TACMessagingDeviceToken.h"
#import "TACMessagingOptions.h"
#import "TACMessagingService.h"
#import "TACMessagingVersion.h"
#import "XGPush.h"

FOUNDATION_EXPORT double TACMessagingVersionNumber;
FOUNDATION_EXPORT const unsigned char TACMessagingVersionString[];

