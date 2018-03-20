//
//  TACPaymentDemoViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2018/1/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TACPaymentDemoViewController.h"
#import <TACPayment/TACPayment.h>
#import <TACCore/TACCore.h>
#import "OpenMidasTool.h"
@interface TACPaymentDemoViewController ()

@end

@implementation TACPaymentDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付";
//    [[TACPaymentService defaultService] ensureStarted:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createOrderChannel:(NSString*)channel completion:(GetPayInfoCompletion)completion
{
    NSString* userID = @"open_midas_test";
    [[TACApplication defaultApplication] bindUserIdentifier:userID];
    OpenMidasTool.sharedInstance.userId = userID;
    OpenMidasTool.sharedInstance.appId = [TACPaymentService defaultService].options.offerId;
    OpenMidasTool.sharedInstance.env = @"release";

    [[OpenMidasTool sharedInstance] placeOrder:channel completion:completion];

}

- (IBAction)payWechat:(id)sender
{
    [self createOrderChannel:@"wechat" completion:^(NSString *payInfo, NSError *error) {
        TACLogDebug(@"下单成功 %@",payInfo);
        
        if (payInfo) {
            [[TACPaymentService defaultService] pay:payInfo appMeataData:nil completation:^(TACPaymentResult * result) {
                TACLogDebug(@"支付结果 %d %@", result.resultCode, result.resultMsg);
            }];
        }
    }];
}

- (IBAction)payQQ:(id)sender {
    [self createOrderChannel:@"qqwallet" completion:^(NSString *payInfo, NSError *error) {
        TACLogDebug(@"下单成功 %@",payInfo);
        if (payInfo) {
            [[TACPaymentService defaultService] pay:payInfo appMeataData:nil completation:^(TACPaymentResult * result) {
                TACLogDebug(@"支付结果 %d %@", result.resultCode, result.resultMsg);
            }];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
