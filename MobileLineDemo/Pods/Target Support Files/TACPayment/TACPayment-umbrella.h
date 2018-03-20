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

#import "TACPayment.h"
#import "TACPaymentContants.h"
#import "TACPaymentOptions.h"
#import "TACPaymentPluginSetupProtocol.h"
#import "TACPaymentResult.h"
#import "TACPaymentService+Private.h"
#import "TACPaymentService.h"
#import "TACPaymentVersion.h"
#import "OpenMidas.h"

FOUNDATION_EXPORT double TACPaymentVersionNumber;
FOUNDATION_EXPORT const unsigned char TACPaymentVersionString[];

