//
//  OpenMidasTool.m
//  OpenMidasSample
//
//  Created by OpenMidas on 14-9-24.
//  Copyright (c) 2017年 Tencent. All rights reserved.
//

#import "OpenMidasTool.h"
#import "MBProgressHUD.h"

@implementation OpenMidasTool
{
    NSMutableData * _dataBuffer;
    GetPayInfoCompletion _block;
}

+ (instancetype)sharedInstance
{
    static OpenMidasTool * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance)
        {
            instance = [[OpenMidasTool alloc] init];
            instance.showLoading = YES;
        }
    });
    
    return instance;
}

- (void)placeOrder:(NSString *)channel completion:(GetPayInfoCompletion)competion;
{
    _block = competion;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"下单中...";
    hud.removeFromSuperViewOnHide = YES;
    
    
    NSString* orderNo;
    NSNumber* orderNumberValue;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"payOrderInfo"]) {
        orderNumberValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"payOrderInfo"];
    } else {
//        orderNumberValue = @(151799749233);
        orderNumberValue = @(151799759233);
    }
    orderNumberValue = [NSNumber numberWithInteger:orderNumberValue.integerValue+1];
    orderNo = [NSString stringWithFormat:@"open_%@",orderNumberValue];
    [[NSUserDefaults standardUserDefaults] setObject:orderNumberValue forKey:@"payOrderInfo"];
    NSDate* currentDate = [NSDate date];
    int64_t timeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval offset = destinationGMTOffset - sourceGMTOffset;
    NSString* UTCTimeInterval = [NSNumber numberWithLongLong:timeInterval-offset].stringValue;
    
    NSString * domain = [NSString stringWithFormat:@"http://carsonxu.com/tac/iOSSandboxOrder.php?domain=api.openmidas.com&appid=TC100009&user_id=rickenwang&out_trade_no=%@&product_id=product_test&currency_type=cny&channel=%@&amount=10&original_amount=10&product_name=test&product_detail=openmidas_android_test&ts=%@&sign=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",orderNo,channel,UTCTimeInterval];
    
    NSLog(@"domain is %@",domain);
//    if ([self.env isEqualToString:@"release"])
//    {
//        domain = @"api.midas.ybsjyyn.com";
//    }
    
//    NSMutableString * reqUrl = [NSMutableString stringWithFormat:@"https://h5.midas.ybsjyyn.com/openmidas/demo-order/order.php?domain=%@&appid=%@", domain, self.appId];
    NSMutableString* reqUrl =domain;
    NSMutableDictionary * post = [@{} mutableCopy];
//
//    post[@"user_id"] = self.userId;
//    post[@"currency_type"] = @"CNY";
//    post[@"amount"] = @(1);
//    post[@"product_id"] = @"201712100001";
//    post[@"product_name"] = [[self class] urlEncode:@"年夜饭10人套餐" count:1];
//    post[@"product_detail"] = [[self class] urlEncode:@"年夜饭10人套餐" count:1];
//    post[@"sign"] = @"sign";
//    NSDate * date = [NSDate date];
//    NSTimeInterval ts = [date timeIntervalSince1970];
//    post[@"out_trade_no"] = [NSString stringWithFormat:@"order_%@", @((unsigned long long)(ts))];
//
//    NSInteger offset = [[NSTimeZone systemTimeZone] secondsFromGMT];
//    post[@"ts"] = @((unsigned long long)(ts - offset));
//    if (channel.length > 0)
//    {
//        post[@"channel"] = channel;
//    }
//
//    NSMutableString * postBody = [@"" mutableCopy];
//    for (NSString * key in post.allKeys)
//    {
//        [postBody appendFormat:@"&%@=%@", key, post[key]];
//    }
//
//    [reqUrl appendFormat:@"%@", postBody];
//
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [req setHTTPMethod:@"GET"];
    
    _dataBuffer = [[NSMutableData alloc] init];
    
    [NSURLConnection connectionWithRequest:req delegate:self];
}

+ (NSString *)urlEncode:(NSString *)str count:(NSInteger) c
{
    if (str.length == 0) {
        NSLog(@"编码内容为空");
        return @"";
    }
    
    NSString * strCpy = [NSString stringWithString:str];
    
    if (c < 1) {
        return strCpy;
    }
    
    
    for (int i = 0; i < c; i++) {
        
        NSString *result = @"";
        
        @try {
            result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (CFStringRef)strCpy,
                                                                                  NULL,
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                  kCFStringEncodingUTF8);
            if (nil != result)
            {
                strCpy = [NSString stringWithString:result];
                CFRelease((__bridge CFTypeRef)(result));
            }
            result = @"";
        }
        @catch (NSException *exception) {
            NSLog(@"url encode err: %@",exception.description);
            result = @"";
            break;
        }
    }
    
    return strCpy;
}

-(void)parseToken
{
    //解析数据
    NSMutableDictionary * result = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:_dataBuffer
                                                                                         options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                                                           error:nil];
    NSLog(@"response : %@", result);
    
    NSNumber * ret = result[@"ret"];
    
    if (_block)
    {
        MBProgressHUD * hud = [MBProgressHUD HUDForView:[UIApplication sharedApplication].keyWindow];
        
        if (ret && 0 == ret.integerValue)
        {
            [hud hideAnimated:NO];
            
            NSString * payInfoString = result[@"pay_info"];
            _block(payInfoString, nil);
        }
        else
        {
            _block(nil, [NSError errorWithDomain:@"OpenMidas" code:-1 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"parseRespError:%@", result]}]);
            
            hud.label.text = @"下单失败，请检查";
            hud.detailsLabel.text = [NSString stringWithFormat:@"下单返回格式错误：%@", result];
            hud.mode = MBProgressHUDModeText;
            
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }
    
    _block = nil;
}

#pragma NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_dataBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString * tokenStr = [[NSString alloc] initWithData:_dataBuffer encoding:NSUTF8StringEncoding];
    NSLog(@"请求完毕, tokenStr : %@", tokenStr);
    
    [self parseToken];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"token请求失败： %@",error.userInfo);
    if (_block)
    {
        _block(nil, error);
    }
    
    _block = nil;
    
    MBProgressHUD * hud = [MBProgressHUD HUDForView:[UIApplication sharedApplication].keyWindow];
    hud.label.text = @"下单失败，请检查";
    hud.detailsLabel.text = error.localizedDescription;
    
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
