//
//  OpenMidasTool.h
//  OpenMidasSample
//
//  Created by OpenMidas on 14-9-24.
//  Copyright (c) 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GetPayInfoCompletion)(NSString * payInfo, NSError * error);

@interface OpenMidasTool : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, retain) NSString * appId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * env;

@property (nonatomic, assign) BOOL showLoading;

+ (NSString *)urlEncode:(NSString *)str count:(NSInteger)c;

- (void)placeOrder:(NSString *)channel completion:(GetPayInfoCompletion)competion;

@end
