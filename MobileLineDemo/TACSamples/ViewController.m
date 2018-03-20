//
//  ViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "ViewController.h"
#import <TACCore/TACCore.h>
#import <AOPKit/AOPKit.h>
#import <TACPayment/TACPayment.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TACAnalyticsService trackEvent:[TACAnalyticsEvent eventWithIdentifier:@"1"]];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
