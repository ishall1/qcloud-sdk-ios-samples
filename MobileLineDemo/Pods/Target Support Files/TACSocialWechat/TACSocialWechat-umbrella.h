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

#import "TACSocialWechat.h"
#import "TACSocialWechatContants.h"
#import "TACSocialWechatOptions.h"
#import "TACSocialWechatService.h"
#import "TACSocialWechatVersion.h"
#import "WechatAuthSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"

FOUNDATION_EXPORT double TACSocialWechatVersionNumber;
FOUNDATION_EXPORT const unsigned char TACSocialWechatVersionString[];

