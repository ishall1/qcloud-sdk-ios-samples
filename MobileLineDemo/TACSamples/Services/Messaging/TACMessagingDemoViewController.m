//
//  TACMessagingDemoViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2017/12/5.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TACMessagingDemoViewController.h"
#import <TACMessaging/TACMessaging.h>

@interface TACMessagingDemoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *applicationBadgeNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *updateBadgeNumberButton;

@end

@implementation TACMessagingDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TACMessagingService defaultService].delegate = self;
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onHandleUpdateBadgeNumberButtonBeClicked:(id)sender {
    if (self.applicationBadgeNumberTextField.text.length == 0) {
        return;
    }
    if (self.applicationBadgeNumberTextField.text.integerValue <= 0) {
        return;
    }
    NSInteger badgeNumber =self.applicationBadgeNumberTextField.text.integerValue;
    [[TACMessagingService defaultService] setApplicationBadgeNumber:badgeNumber];
}
- (IBAction)onHandleStartReceiveNotificationBeClicked:(id)sender {
    
    [[TACMessagingService defaultService] startReceiveNotifications];
    
}
- (IBAction)onHandleStopReceiveNotificationButtonBeClicked:(id)sender {
    [[TACMessagingService defaultService] stopReceiveNotifications];
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
