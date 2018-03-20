//
//  TACCrashMockListTableViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2018/2/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TACCrashMockListTableViewController.h"
#import "CRLCrash.h"
#import <objc/runtime.h>
#import "TACCrashDetailViewController.h"
@interface TACCrashMockListTableViewController ()
@property(nonatomic,strong) NSDictionary *knownCrashes;

@end

@implementation TACCrashMockListTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self pokeAllCrashes];
    
    NSMutableArray *crashes = [NSMutableArray arrayWithArray:[CRLCrash allCrashes]];
    [crashes sortUsingComparator:^NSComparisonResult(CRLCrash *obj1, CRLCrash *obj2) {
        if ([obj1.category isEqualToString:obj2.category]) {
            return [obj1.title compare:obj2.title];
        } else {
            return [obj1.category compare:obj2.category];
        }
    }];
    
    NSMutableDictionary *categories = @{}.mutableCopy;
    
    for (CRLCrash *crash in crashes)
        categories[crash.category] = [(categories[crash.category] ?: @[]) arrayByAddingObject:crash];
    
    self.knownCrashes = categories.copy;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"crash"];
}

- (void)pokeAllCrashes
{
    unsigned int nclasses = 0;
    Class *classes = objc_copyClassList(&nclasses);
    
    for (unsigned int i = 0; i < nclasses; ++i) {
        if (classes[i] &&
            class_getSuperclass(classes[i]) == [CRLCrash class] &&
            class_respondsToSelector(classes[i], @selector(methodSignatureForSelector:)) &&
            classes[i] != [CRLCrash class])
        {
            [CRLCrash registerCrash:[[classes[i] alloc] init]];
        }
    }
    free(classes);
}

- (NSArray *)sortedAllKeys {
    NSMutableArray *result = [NSMutableArray arrayWithArray:self.knownCrashes.allKeys];
    
    [result sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    return [result copy];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (NSInteger)self.knownCrashes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sortedAllKeys[(NSUInteger)section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)((NSArray *)self.knownCrashes[self.sortedAllKeys[(NSUInteger)section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"crash" forIndexPath:indexPath];
    CRLCrash *crash = (CRLCrash *)(((NSArray *)self.knownCrashes[self.sortedAllKeys[(NSUInteger)indexPath.section]])[(NSUInteger)indexPath.row]);
    
    cell.textLabel.text = crash.title;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CRLCrash *crash = (CRLCrash *)(((NSArray *)self.knownCrashes[self.sortedAllKeys[(NSUInteger)indexPath.section]])[(NSUInteger)indexPath.row]);
    TACCrashDetailViewController* vc = [TACCrashDetailViewController new];
    vc.detailItem = crash;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
