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

#import "TACAnalytics.h"
#import "TACAnalyticsEvent.h"
#import "TACAnalyticsOptions.h"
#import "TACAnalyticsProperties.h"
#import "TACAnalyticsService.h"
#import "TACAnalyticsStrategy.h"
#import "TACNetworkMetrics.h"
#import "TACApplication+Private.h"
#import "TACApplication.h"
#import "TACApplicationOptions.h"
#import "TACBaseOptions.h"
#import "TACCoreConstants.h"
#import "TACModuleConfigurateProtocol.h"
#import "TACProjectOptions.h"
#import "TACRuningEnviroment.h"
#import "TACSetupApplicationOptions.h"
#import "TACLogger.h"
#import "TACCore.h"
#import "TACCoreVersion.h"
#import "MTA.h"
#import "MTAConfig.h"
#import "MTACrashReporter.h"
#import "MTAAutoTrack.h"
#import "FBI.h"
#import "Installtracker.h"
#import "MTAInstallConfig.h"
#import "MTAHybrid.h"
#import "MTALBS.h"

FOUNDATION_EXPORT double TACCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char TACCoreVersionString[];

