//
//  TACAnalyticsDemoViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2017/12/5.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TACAnalyticsDemoViewController.h"
#import <TACCore/TACCore.h>
@interface TACAnalyticsDemoViewController ()
@property (nonatomic, strong) TACAnalyticsEvent* durationEvent;
@end

@implementation TACAnalyticsDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TACAnalyticsEvent* event = [TACAnalyticsEvent eventWithIdentifier:@"duration-event"];
    _durationEvent = event;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    TACAnalyticsEvent* event = [TACAnalyticsEvent eventWithIdentifier:@"demo-appear-event"];
    [TACAnalyticsService trackEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)durationStart:(id)sender
{
    [TACAnalyticsService trackEventDurationBegin:_durationEvent];
}

- (IBAction)durationEnd:(id)sender
{
    [TACAnalyticsService trackEventDurationEnd:_durationEvent];
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
