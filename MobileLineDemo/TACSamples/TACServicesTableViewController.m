//
//  TACServicesTableViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2017/12/5.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TACServicesTableViewController.h"
#import "TACAnalyticsDemoViewController.h"
#import "TACMessagingDemoViewController.h"
#import "TACStorageDemoViewController.h"
#import "TACSoicalDemoViewController.h"
#import "TACPaymentDemoViewController.h"
#import "TACCrashMockListTableViewController.h"
@interface TACServiceModel :NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) Class doorViewControllerClass;
@end

@implementation TACServiceModel

@end

@interface TACServicesTableViewController ()
@property (nonatomic, strong) NSArray* services;
@end

@implementation TACServicesTableViewController

static NSString* const kTACCellServiceIdentifier = @"service";
- (void) prepareDatas
{
    NSMutableArray* servicesCache = [NSMutableArray new];
    
    void(^AddService)(NSString* name, Class door) = ^(NSString* name ,Class door) {
        TACServiceModel* model = [TACServiceModel new];
        model.name = name;
        model.doorViewControllerClass = door;
        [servicesCache addObject:model];
    };
    
    
    AddService(@"崩溃监测Crash", TACCrashMockListTableViewController.class);
    AddService(@"存储模块Storage", TACStorageDemoViewController.class);
    AddService(@"统计分析Analytics", TACAnalyticsDemoViewController.class);
    AddService(@"消息推送Messaging", TACMessagingDemoViewController.class);
    AddService(@"社交模块Social", TACSoicalDemoViewController.class);
    AddService(@"支付木块Payment", TACPaymentDemoViewController.class);
    
    _services = [servicesCache copy];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //
    self.title = @"应用云体验Demo";
    [self prepareDatas];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTACCellServiceIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHandleGotAPNSToken:) name:@"GotAPNSToken" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTACCellServiceIdentifier forIndexPath:indexPath];
    
    TACServiceModel* model = self.services[indexPath.row];
    cell.textLabel.text = model.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TACServiceModel* model = self.services[indexPath.row];
    if (model.doorViewControllerClass) {
        UIViewController* vc = [model.doorViewControllerClass new];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        @throw [NSException exceptionWithName:@"com.tencent.qcloud.tac.error" reason:[NSString stringWithFormat:@"当前服务模型没有入口视图%@",model.name] userInfo:nil];
    }
}

- (void)onHandleGotAPNSToken:(NSNotification*)notification {
    NSString* message ;
    if ([notification.object isKindOfClass:[NSData class]]) {
        message = ((NSData*)notification.object).description;
    }
    UIAlertController* alert =[UIAlertController alertControllerWithTitle:@"Got APNS Token" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
