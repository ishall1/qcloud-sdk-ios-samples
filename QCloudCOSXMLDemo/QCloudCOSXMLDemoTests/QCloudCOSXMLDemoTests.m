//
//  QCloudCOSXMLDemoTests.m
//  QCloudCOSXMLDemoTests
//
//  Created by Dong Zhao on 2017/2/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//



#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import "TestCommonDefine.h"

@interface QCloudCOSXMLDemoTests : XCTestCase <QCloudSignatureProvider>
@property (nonatomic, strong) NSString* aclBucket;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, strong) NSString* ownerID;
@end

@implementation QCloudCOSXMLDemoTests

- (void)setUp {
    [super setUp];
    self.aclBucket = @"tjtest";
    self.appID =  @"您的APPID";
    self.ownerID = @"账号对应QQ号";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testRegisterCustomService
{
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"***";
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"cn-south";
    configuration.endpoint = endpoint;
    
    NSString* serviceKey = @"test";
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:serviceKey];
    QCloudCOSXMLService* service = [QCloudCOSXMLService cosxmlServiceForKey:serviceKey];
    XCTAssertNotNil(service);
}

- (void) testGetACL {
    QCloudGetObjectACLRequest* request = [QCloudGetObjectACLRequest new];
    request.bucket = self.aclBucket;
    request.object = @"test1.jpg";
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudACLPolicy* policy;
    [request setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
        policy = result;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetObjectACL:request];
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertNotNil(policy);
    NSString* expectedIdentifier = [NSString identifierStringWithID:self.ownerID :self.ownerID];
    XCTAssert([policy.owner.identifier isEqualToString:expectedIdentifier]);
    XCTAssert(policy.accessControlList.count == 1);
        XCTAssert([[policy.accessControlList firstObject].grantee.identifier isEqualToString:[NSString identifierStringWithID:@"***" :@"***"]]);
}

- (NSString*) uploadTempObject
{
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.aclBucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    return put.object;
}
- (void) testDeleteObject
{
    NSString* object = [self uploadTempObject];
    QCloudDeleteObjectRequest* deleteObjectRequest = [QCloudDeleteObjectRequest new];
    deleteObjectRequest.bucket = self.aclBucket;
    deleteObjectRequest.object = object;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block NSError* localError;
    [deleteObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertNil(localError);
}



- (void) testDeleteObjects
{
    NSString* object1 = [self uploadTempObject];
    NSString* object2 = [self uploadTempObject];
    
    QCloudDeleteMultipleObjectRequest* delteRequest = [QCloudDeleteMultipleObjectRequest new];
    delteRequest.bucket = self.aclBucket;
    
    QCloudDeleteObjectInfo* object = [QCloudDeleteObjectInfo new];
    object.key = object1;
    
    QCloudDeleteObjectInfo* deleteObject2 = [QCloudDeleteObjectInfo new];
    deleteObject2.key = object2;
    
    QCloudDeleteInfo* deleteInfo = [QCloudDeleteInfo new];
    deleteInfo.quiet = NO;
    deleteInfo.objects = @[ object,deleteObject2];
    
    delteRequest.deleteObjects = deleteInfo;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block NSError* localError;
    __block QCloudDeleteResult* deleteResult = nil;
    [delteRequest setFinishBlock:^(QCloudDeleteResult* outputObject, NSError *error) {
        localError = error;
        deleteResult = outputObject;
        [exp fulfill];
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:delteRequest];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertNotNil(deleteResult);
    XCTAssertEqual(2, deleteResult.deletedObjects.count);
    QCloudDeleteResultRow* firstrow =  deleteResult.deletedObjects[0];
    QCloudDeleteResultRow* secondRow = deleteResult.deletedObjects[1];
    
    XCTAssert([firstrow.key isEqualToString:object1]);
    XCTAssert([secondRow.key isEqualToString:object2]);
    
    
}
- (void) testPutObjectACL
{
    NSString* object = [self uploadTempObject];
    QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
    request.object = object;
    request.bucket = self.aclBucket;
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"2779643970", @"2779643970"];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    request.grantFullControl = grantString;    
    QCloudACLOwner* owner = [QCloudACLOwner new];
    owner.identifier = self.appID;
    owner.displayName = @"testDisplayName";
    XCTestExpectation* exp = [self expectationWithDescription:@"acl"];
    __block NSError* localError;
    [request setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
    [self waitForExpectationsWithTimeout:1000 handler:nil];
    XCTAssertNil(localError);
    
}

- (void) testPutObject {
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket =self.aclBucket;
    put.body =  [@"1234jdjdjdjjdjdjyuehjshgdytfakjhsghgdhg" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"2779643970", @"2779643970"];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    put.grantRead = put.grantWrite = put.grantFullControl = grantString;
    
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];

    [put setFinishBlock:^(id outputObject, NSError *error) {
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void) testInitMultipartUpload {
    QCloudInitiateMultipartUploadRequest* initrequest = [QCloudInitiateMultipartUploadRequest new];
    initrequest.bucket = self.aclBucket;
    initrequest.object = [NSUUID UUID].UUIDString;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudInitiateMultipartUploadResult* initResult;
    [initrequest setFinishBlock:^(QCloudInitiateMultipartUploadResult* outputObject, NSError *error) {
        initResult = outputObject;
        [exp fulfill];
    }];

    [[QCloudCOSXMLService defaultCOSXML] InitiateMultipartUpload:initrequest];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
    }];
    NSString* expectedBucketString = [NSString stringWithFormat:@"%@-%@",self.aclBucket,self.appID];
    XCTAssert([initResult.bucket isEqualToString:expectedBucketString]);
    XCTAssert([initResult.key isEqualToString:initrequest.object]);
    
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
- (void) testHeadeObject   {
    NSString* object = [self uploadTempObject];
    QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
    headerRequest.object = object;
    headerRequest.bucket = self.aclBucket;
    
    XCTestExpectation* exp = [self expectationWithDescription:@"header"];
    __block id resultError;
    [headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
        resultError = error;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    XCTAssertNil(resultError);
}


- (void)testOptionObject {
    QCloudOptionsObjectRequest* request = [[QCloudOptionsObjectRequest alloc] init];
    request.bucket = self.aclBucket;
    request.origin = @"http://www.qcloud.com";
    request.accessControlRequestMethod = @"GET";
    request.accessControlRequestHeaders = @"origin";
    request.object = @"test1.jpg";
    XCTestExpectation* exp = [self expectationWithDescription:@"option object"];

    __block id resultError;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] OptionsObject:request];
    
    [self waitForExpectationsWithTimeout:80 handler:^(NSError * _Nullable error) {
        
    }];
    XCTAssertNil(resultError);
}

- (void) testAppendObject {
    QCloudAppendObjectRequest* put = [QCloudAppendObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.aclBucket;
    put.body =  [NSURL fileURLWithPath:[self tempFileWithSize:1024*1024*1]];
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",@"2779643970", @"2779643970"];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    put.grantRead = put.grantWrite = put.grantFullControl = grantString;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block NSDictionary* result = nil;
    [put setFinishBlock:^(id outputObject, NSError *error) {
        result = outputObject;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] AppendObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    XCTAssertNotNil(result);
}

- (void) testLittleLimitAppendObject {
    QCloudAppendObjectRequest* put = [QCloudAppendObjectRequest new];
    put.object = [NSUUID UUID].UUIDString;
    put.bucket = self.aclBucket;
    put.body =  [NSURL fileURLWithPath:[self tempFileWithSize:1024*2]];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block NSDictionary* result = nil;
    __block NSError* error;
    [put setFinishBlock:^(id outputObject, NSError *servererror) {
        result = outputObject;
        error = servererror;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] AppendObject:put];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    XCTAssertNotNil(error);
}

- (void) testGetObject {
    QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
    NSString* object =  [NSUUID UUID].UUIDString;
    put.object =object;
    put.bucket = self.aclBucket;
    NSURL* fileURL = [NSURL fileURLWithPath:[self tempFileWithSize:1024*1024*3]];
    put.body = fileURL;

    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudGetObjectRequest* request = [QCloudGetObjectRequest new];
    request.downloadingURL = [NSURL URLWithString:QCloudTempFilePathWithExtension(@"downding")];
    
    [put setFinishBlock:^(id outputObject, NSError *error) {
        request.object = object;
        request.bucket = self.aclBucket;
        request.responseContentType = @"text/html";
        request.responseContentLanguage = @"zh-CN";
        request.responseContentExpires = @"contentExpires";
        request.responseCacheControl = @"cacheControlTest";
        request.responseContentDisposition = @"test";
        request.responseContentEncoding = @"test";
        [request setFinishBlock:^(id outputObject, NSError *error) {
            [exp fulfill];
        }];
        [request setDownProcessBlock:^(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload) {
            NSLog(@"⏬⏬⏬⏬DOWN [Total]%lld  [Downloaded]%lld [Download]%lld", totalBytesExpectedToDownload, totalBytesDownload, bytesDownload);
        }];
        [[QCloudCOSXMLService defaultCOSXML] GetObject:request];
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutObject:put];
    
    [self waitForExpectationsWithTimeout:80 handler:nil];
    
    XCTAssertEqual(QCloudFileSize(request.downloadingURL.path), QCloudFileSize(fileURL.path));
    
}
@end
