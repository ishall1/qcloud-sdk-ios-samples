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

#import "TACAuthorization.h"
#import "TACAuthorizationContants.h"
#import "TACAuthorizationOptions.h"
#import "TACAuthorizationVersion.h"
#import "TACAuthoriztionService+Private.h"
#import "TACAuthoriztionService.h"
#import "TACAuthProvider.h"
#import "TACCredential.h"
#import "TACOAuth2Credential.h"
#import "TACOpenUserInfo.h"

FOUNDATION_EXPORT double TACAuthorizationVersionNumber;
FOUNDATION_EXPORT const unsigned char TACAuthorizationVersionString[];

