//
//  TACCrashDetailViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2018/2/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TACCrashDetailViewController.h"

@interface TACCrashDetailViewController ()
@property(strong,nonatomic) IBOutlet UILabel *titleLabel;
@property(strong,nonatomic) IBOutlet UILabel *descriptionLabel;
@property(strong,nonatomic) IBOutlet UIImageView *descriptionImage;

- (IBAction)doCrash;
@end

@implementation TACCrashDetailViewController
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.titleLabel.text = self.detailItem.title;
    self.descriptionLabel.text = self.detailItem.desc;
    //    self.descriptionImage.image = nil;
    self.navigationItem.title = @"Crash";
}

- (IBAction)doCrash
{
    [self.detailItem crash];
}


@end
