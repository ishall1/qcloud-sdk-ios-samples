//
//  TACStoragePathTest.m
//  TACSamplesTests
//
//  Created by Dong Zhao on 2017/11/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TACStorage.h"
@interface TACStoragePathTest : XCTestCase

@end

@implementation TACStoragePathTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void) testParseURLString {
    TACStoragePath* path = [TACStoragePath parseFromHTTPURL:@"https://bucket-12232.cos.beijing.myqcloud.com/object/path"];
    XCTAssert([path.bucket isEqualToString:@"bucket-12232"]);
    XCTAssert([path.object isEqualToString:@"object/path"]);
    XCTAssert([path.region isEqualToString:@"beijing"]);
    
    TACStoragePath* parent = [path parent];
    XCTAssert([parent.bucket isEqualToString:@"bucket-12232"]);
    XCTAssert([parent.object isEqualToString:@"object"]);
    XCTAssert([parent.region isEqualToString:@"beijing"]);
    
    TACStoragePath* root = [parent root];
    XCTAssert([root.bucket isEqualToString:@"bucket-12232"]);
    XCTAssert(!root.object);
    XCTAssert([root.region isEqualToString:@"beijing"]);
    
    XCTAssert([root isEqualToStoragePath:[path root]]);
}


- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
