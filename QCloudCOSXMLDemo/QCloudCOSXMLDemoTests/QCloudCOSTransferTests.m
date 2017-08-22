//
//  QCloudCOSTransferTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#define CNNORTH_REGION
#import "TestCommonDefine.h"
#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
@interface QCloudCOSTransferTests : XCTestCase <QCloudSignatureProvider>
@property (nonatomic, strong) NSString* bucket;
@end

@implementation QCloudCOSTransferTests


- (void)setUp {
    [super setUp];
#warning 填入您的bucket
#ifdef CNNORTH_REGION
    self.bucket = @"tjtest";
#else 
    self.bucket = @"xy2";
#endif
}

- (void)tearDown {
    [super tearDown];
}
- (NSString*) tempFileWithSize:(int)size
{
    NSString* file4MBPath = QCloudPathJoin(QCloudTempDir(), [NSUUID UUID].UUIDString);
    
    if (!QCloudFileExist(file4MBPath)) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    int aimMem = size;
    for (int writedMem = 0; writedMem <= aimMem; ) {
        int aimSlice = 512;
        aimSlice = MIN(aimSlice, aimMem - writedMem);
        if (aimSlice == 0) {
            break;
        }
        char* mem = malloc(sizeof(char)*aimSlice);
        NSData* data = [NSData dataWithBytes:mem length:aimSlice];
        [handler writeData:data];
        free(mem);
        writedMem += aimSlice;
    }
    [handler closeFile];
    return file4MBPath;
}

- (void) testRegisterCustomManagerService
{
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"您的APPID";
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"cn-south";
    configuration.endpoint = endpoint;
    
    NSString* serviceKey = @"test";
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:serviceKey];
    
    QCloudCOSTransferMangerService* service = [QCloudCOSTransferMangerService costransfermangerServiceForKey:serviceKey];
    XCTAssertNotNil(service);
}

- (void) testMultiUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:150*1024*1024 + randomNumber]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}

- (void)testIntegerTimesSliceMultipartUpload {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:50*1024*1024 ]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
}


- (void)testSmallSizeUpload {
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:1024 ]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    XCTestExpectation* exp = [self expectationWithDescription:@"delete33"];
    __block id result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    [self waitForExpectationsWithTimeout:18000 handler:^(NSError * _Nullable error) {
    }];
    XCTAssertNotNil(result);
    
}
- (void) testAbortMultiUpload{
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    int randomNumber = arc4random()%100;
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:304*1024*1024 + randomNumber]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];
    XCTestExpectation* hintExp = [self expectationWithDescription:@"abort"];

    __block id abortResult = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [put abort:^(id outputObject, NSError *error) {
            abortResult = outputObject;
            [hintExp fulfill];
        }];
        
    });
    [self waitForExpectationsWithTimeout:80000 handler:nil];
    XCTAssertNotNil(abortResult);
}

- (void) testPauseAndResume {
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL fileURLWithPath:[self tempFileWithSize:30*1024*1024]];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.bucket;
    put.body =  url;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudUploadObjectResult* result;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
    [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:put];

    __block QCloudCOSXMLUploadObjectResumeData resumeData = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSError* error;
        resumeData = [put cancelByProductingResumeData:&error];

    });
    [self waitForExpectationsWithTimeout:80000 handler:nil];
    
    XCTestExpectation* resumeExp = [self expectationWithDescription:@"delete2"];
    if (resumeData) {
        QCloudCOSXMLUploadObjectRequest* request = [QCloudCOSXMLUploadObjectRequest requestWithRequestData:resumeData];
        [request setFinishBlock:^(QCloudUploadObjectResult* outputObject, NSError *error) {
            result = outputObject;
            [resumeExp fulfill];
        }];
        
        [request setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }];
        [[QCloudCOSTransferMangerService defaultCOSTRANSFERMANGER] UploadObject:request];
    } else {
        [resumeExp fulfill];
    }
    [self waitForExpectationsWithTimeout:80000 handler:nil];
    XCTAssertNotNil(result);
    XCTAssertNotNil(result.location);
    XCTAssertNotNil(result.eTag);
}
@end
