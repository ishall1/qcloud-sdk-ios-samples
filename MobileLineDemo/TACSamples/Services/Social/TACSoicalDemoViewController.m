//
//  TACSoicalDemoViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2017/12/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TACSoicalDemoViewController.h"
#import <TACAuthorizationQQ/TACAuthorizationQQ.h>
#import <TACAuthorizationWechat/TACAuthorizationWechat.h>
#import <TACCore/TACCore.h>

@interface TACSoicalDemoViewController ()
@property (nonatomic, weak) IBOutlet UIImageView* avatarImageView;
@end

@implementation TACSoicalDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)qqLogin:(id)sender
{
    TACQQAuthProvider* provider = [[TACAuthoriztionService defaultService] qqCredentialProvider];
    [provider requestCredential:^(TACQQCredential*credential, NSError *error) {
        if (error) {
            TACLogError(@"ERROR %@", error);
        } else {
            [provider requestUserInfoWithCredential:credential completation:^(TACOpenUserInfo *userInfo, NSError *error) {
                
            }];
            
            TACLogDebug(@"Credential %@", credential);
        }
    }];
}

- (IBAction)wechatLogin:(id)sender
{
    TACWechatAuthProvider* provider = [[TACAuthoriztionService defaultService] wechatCredentialProvider];
    [provider requestCredential:^(TACCredential *credential, NSError *error) {
        if (error) {
            TACLogError(@"ERROR %@", error);
        } else {
            [provider requestUserInfoWithCredential:credential completation:^(TACOpenUserInfo *userInfo, NSError *error) {
                
            }];
            TACLogDebug(@"Credential %@", credential);
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
