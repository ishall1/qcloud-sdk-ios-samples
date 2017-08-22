//
//  QCloudCOSXMLExceptionCoverage.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 21/08/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestCommonDefine.h"
#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import  "NSObject+QCloudModel.h"
#import "QCloudCOSAccountTypeEnum.h"
#import "QCloudCompleteMultipartUploadInfo.h"
#import "QCloudDeleteInfo.h"
#import "QCloudDeleteObjectInfo.h"
@interface QCloudCOSXMLExceptionCoverage : XCTestCase

@end

@implementation QCloudCOSXMLExceptionCoverage

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testCommonPrefix {
    QCloudCommonPrefixes* prefix = [QCloudCommonPrefixes new];
    NSDictionary* inputDict = @{@"Prefix":@"afsd"};
    id output = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil];
    XCTAssertNil(output);
    NSDictionary* transOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:inputDict];
    XCTAssert([transOutput[@"Prefix"][0] isEqualToString:@"afsd"]);
    
    NSDictionary* transArrayiutput = @{@"Prefix":@[@"aaa",@"bbb"]};
    NSDictionary* transArrayOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:transArrayiutput];
    XCTAssertEqual([transArrayOutput[@"Prefix"] count],2);
                   
   NSDictionary* dictInput = @{@"Prefix":@{@"jiangzhuxi":@[@"123",@"456"]}};
   NSDictionary* dicOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput];
    XCTAssert([dicOutput[@"Prefix"] isKindOfClass:[NSArray class]]);
    
    NSDictionary* dictInput2 = @{@"Prefix":@{@"jiangzhuxi":@{@"aa":@"bb"}}};
    NSDictionary* dictOutput2 = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput2];
     XCTAssert([dictOutput2[@"Prefix"] isKindOfClass:[NSArray class]]);


    NSDictionary* nilInput =@{@"Prefix":[NSNull null]};
    NSDictionary* nilOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nilInput];
    XCTAssertNil(nilOutput[@"prefix"]);
    
    
    NSDictionary* wrapper = [[prefix class] modelCustomPropertyMapper];
    XCTAssert([wrapper[@"prefix"] isEqualToString:@"Prefix"]);
    
    XCTAssert([prefix performSelector:@selector(modelCustomTransformToDictionary:) withObject:nilInput]);
    
    NSDictionary* genericClass = [[prefix class] modelContainerPropertyGenericClass];
    XCTAssertNotNil(genericClass);
}


- (void)testTypeNum {
    XCTAssertEqual(QCloudCOSAccountTypeDumpFromString(@"RootAccount"),0);
    XCTAssertEqual(QCloudCOSAccountTypeDumpFromString(@"SubAccount"),1);
    
    XCTAssert([QCloudCOSAccountTypeTransferToString(QCloudCOSAccountTypeRoot) isEqualToString:@"RootAccount"]);
    XCTAssert([QCloudCOSAccountTypeTransferToString(QCloudCOSAccountTypeSub) isEqualToString:@"SubAccount"]);
}

- (void)testStorateEnum {
    XCTAssertEqual(QCloudCOSStorageClassDumpFromString(@"Standard"),0);
    XCTAssertEqual(QCloudCOSStorageClassDumpFromString(@"Standard_IA"),1);
    XCTAssertEqual(QCloudCOSStorageClassDumpFromString(@"Nearline"),2);
    
    XCTAssert([QCloudCOSStorageClassTransferToString(QCloudCOSStorageStandard) isEqualToString:@"Standard"]);
    XCTAssert([QCloudCOSStorageClassTransferToString(QCloudCOSStorageStandardIA) isEqualToString:@"Standard_IA"]);
    XCTAssert([QCloudCOSStorageClassTransferToString(QCloudCOSStorageNearline) isEqualToString:@"Nearline"]);
    
}

- (void)testDeleteMultipartInfo {
    QCloudCompleteMultipartUploadInfo* prefix = [QCloudCompleteMultipartUploadInfo new];
    NSDictionary* inputDict = @{@"Part":@"afsd"};
    id output = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil];
    XCTAssertNil(output);
    NSDictionary* transOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:inputDict];
    XCTAssert([transOutput[@"Part"][0] isEqualToString:@"afsd"]);
    
    NSDictionary* transArrayiutput = @{@"Part":@[@"aaa",@"bbb"]};
    NSDictionary* transArrayOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:transArrayiutput];
    XCTAssertEqual([transArrayOutput[@"Part"] count],2);
    
    NSDictionary* dictInput = @{@"Part":@{@"jiangzhuxi":@[@"123",@"456"]}};
    NSDictionary* dicOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput];
    XCTAssert([dicOutput[@"Part"] isKindOfClass:[NSArray class]]);
    
    NSDictionary* dictInput2 = @{@"Part":@{@"jiangzhuxi":@{@"aa":@"bb"}}};
    NSDictionary* dictOutput2 = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput2];
    XCTAssert([dictOutput2[@"Part"] isKindOfClass:[NSArray class]]);
    
    
    NSDictionary* nilInput =@{@"Part":[NSNull null]};
    NSDictionary* nilOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nilInput];
    XCTAssert([nilOutput[@"Part"] isKindOfClass:[NSNull class]]);
    
    
    NSDictionary* wrapper = [[prefix class] modelCustomPropertyMapper];
    XCTAssert([wrapper[@"parts"] isEqualToString:@"Part"]);
    
    XCTAssert([prefix performSelector:@selector(modelCustomTransformToDictionary:) withObject:nilInput]);
    
    NSDictionary* genericClass = [[prefix class] modelContainerPropertyGenericClass];
    XCTAssertNotNil(genericClass);
}

- (void)testDeleteInfo {
    QCloudDeleteInfo* prefix = [QCloudDeleteInfo new];
    NSDictionary* inputDict = @{@"Object":@"afsd"};
    id output = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil];
    XCTAssertNil(output);
    NSDictionary* transOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:inputDict];
    XCTAssert([transOutput[@"Object"][0] isEqualToString:@"afsd"]);
    
    NSDictionary* transArrayiutput = @{@"Object":@[@"aaa",@"bbb"]};
    NSDictionary* transArrayOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:transArrayiutput];
    XCTAssertEqual([transArrayOutput[@"Object"] count],2);
    
    NSDictionary* dictInput = @{@"Object":@{@"jiangzhuxi":@[@"123",@"456"]}};
    NSDictionary* dicOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput];
    XCTAssert([dicOutput[@"Object"] isKindOfClass:[NSArray class]]);
    
    NSDictionary* dictInput2 = @{@"Object":@{@"jiangzhuxi":@{@"aa":@"bb"}}};
    NSDictionary* dictOutput2 = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput2];
    XCTAssert([dictOutput2[@"Object"] isKindOfClass:[NSArray class]]);
    
    
    NSDictionary* nilInput =@{@"Object":[NSNull null]};
    NSDictionary* nilOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nilInput];
    XCTAssert([nilOutput[@"Object"] isKindOfClass:[NSNull class]]);
    
    
    NSDictionary* wrapper = [[prefix class] modelCustomPropertyMapper];
    XCTAssert([wrapper[@"objects"] isEqualToString:@"Object"]);
    
    XCTAssert([prefix performSelector:@selector(modelCustomTransformToDictionary:) withObject:nilInput]);
    
    NSDictionary* genericClass = [[prefix class] modelContainerPropertyGenericClass];
    XCTAssertNotNil(genericClass);
}

- (void)testDeleteObjectInfo {
    QCloudDeleteObjectInfo* info = [[QCloudDeleteObjectInfo alloc] init];
    XCTAssertNil([info performSelector:@selector(modelCustomWillTransformFromDictionary:
                                                             ) withObject:nil]);
    NSDictionary* dict = @{@"aaa":@"vvv"};
    XCTAssert([[info performSelector:@selector(modelCustomWillTransformFromDictionary:
                                                          ) withObject:dict][@"aaa"] isEqualToString:@"vvv"]);
}


- (void)testDeleteResult {
    QCloudDeleteResult* prefix = [QCloudDeleteResult new];
    NSDictionary* inputDict = @{@"Deleted":@"afsd"};
    id output = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil];
    XCTAssertNil(output);
    NSDictionary* transOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:inputDict];
    XCTAssert([transOutput[@"Deleted"][0] isEqualToString:@"afsd"]);
    
    NSDictionary* transArrayiutput = @{@"Deleted":@[@"aaa",@"bbb"]};
    NSDictionary* transArrayOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:transArrayiutput];
    XCTAssertEqual([transArrayOutput[@"Deleted"] count],2);
    
    NSDictionary* dictInput = @{@"Deleted":@{@"jiangzhuxi":@[@"123",@"456"]}};
    NSDictionary* dicOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput];
    XCTAssert([dicOutput[@"Deleted"] isKindOfClass:[NSArray class]]);
    
    NSDictionary* dictInput2 = @{@"Deleted":@{@"jiangzhuxi":@{@"aa":@"bb"}}};
    NSDictionary* dictOutput2 = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput2];
    XCTAssert([dictOutput2[@"Deleted"] isKindOfClass:[NSArray class]]);
    
    
    NSDictionary* nilInput =@{@"Deleted":[NSNull null]};
    NSDictionary* nilOutput = [prefix performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nilInput];
    XCTAssert([nilOutput[@"Deleted"] isKindOfClass:[NSNull class]]);
    
    
    NSDictionary* wrapper = [[prefix class] modelCustomPropertyMapper];
    XCTAssert([wrapper[@"deletedObjects"] isEqualToString:@"Deleted"]);
    
    XCTAssert([prefix performSelector:@selector(modelCustomTransformToDictionary:) withObject:nilInput]);
    
    NSDictionary* genericClass = [[prefix class] modelContainerPropertyGenericClass];
    XCTAssertNotNil(genericClass);

}



- (void)testCORSRule {
    QCloudCORSRule* rule = [[QCloudCORSRule alloc] init];
    NSDictionary* inputDict = @{@"AllowedMethod":@"HEAD"};
    id output = [rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil];
    XCTAssertNil(output);
    NSDictionary* transOutput = [rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:inputDict];
    XCTAssert([transOutput[@"AllowedMethod"][0] isEqualToString:@"HEAD"]);
    
    NSDictionary* transArrayiutput = @{@"AllowedMethod":@[@"aaa",@"bbb"]};
    NSDictionary* transArrayOutput = [rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:transArrayiutput];
    XCTAssertEqual([transArrayOutput[@"AllowedMethod"] count],2);
    
    NSDictionary* dictInput = @{@"AllowedMethod":@{@"2222":@[@"123",@"456"]}};
    NSDictionary* dicOutput = [rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput];
    XCTAssert([dicOutput[@"AllowedMethod"] isKindOfClass:[NSArray class]]);
    
    NSDictionary* dictInput2 = @{@"AllowedMethod":@{@"2222":@{@"aa":@"bb"}}};
    NSDictionary* dictOutput2 = [rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dictInput2];
    XCTAssert([dictOutput2[@"AllowedMethod"] isKindOfClass:[NSArray class]]);
    
    
    NSDictionary* nilInput =@{@"AllowedMethod":[NSNull null]};
    NSDictionary* nilOutput = [rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nilInput];
    XCTAssert([nilOutput[@"AllowedMethod"] isKindOfClass:[NSNull class]]);
    
    
    NSDictionary* wrapper = [[rule class] modelCustomPropertyMapper];
    XCTAssert([wrapper[@"allowedMethod"] isEqualToString:@"AllowedMethod"]);
    
    XCTAssert([rule performSelector:@selector(modelCustomTransformToDictionary:) withObject:nilInput]);
    XCTAssertNil([rule performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil]);
    NSDictionary* genericClass = [[rule class] modelContainerPropertyGenericClass];
    XCTAssertNotNil(genericClass);

    
}

- (void)testBucketTag {
    QCloudBucketTag* bucketTag = [QCloudBucketTag new];
    
    
    XCTAssertNotNil([[bucketTag class] modelCustomPropertyMapper]);

    
    XCTAssertNil([bucketTag performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:nil]);
    NSDictionary* dict = @{@"aaa":@"vvv"};
    XCTAssertNotNil([bucketTag performSelector:@selector(modelCustomWillTransformFromDictionary:) withObject:dict]);

}


@end
