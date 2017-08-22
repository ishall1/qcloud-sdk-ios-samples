//
//  QCloudCOSXMLBucketTests.m
//  QCloudCOSXMLDemo
//
//  Created by Dong Zhao on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudServiceConfiguration_Private.h>
#import <QCloudCore/QCloudAuthentationCreator.h>
#import <QCloudCore/QCloudCredential.h>
#import <QCloudCore/QCloudCore.h>
#import "TestCommonDefine.h"
#import "QCloudCOSXMLServiceUtilities.h"
@interface QCloudCOSXMLBucketTests : XCTestCase
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* appID;
@end






@implementation QCloudCOSXMLBucketTests



- (void)setUp {
    [super setUp];
#ifdef CNNORTH_REGION
    self.bucket = @"tjtest";
#else
    self.bucket = @"xy2";
#endif
    self.appID = @"您的APPID";
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}




- (void) testGetBucket {
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    request.bucket = self.bucket;
    request.maxKeys = 1000;
    request.prefix = @"0";
    request.delimiter = @"0";
    request.encodingType = @"url";
    
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block QCloudListBucketResult* listResult;
    [request setFinishBlock:^(QCloudListBucketResult * _Nonnull result, NSError * _Nonnull error) {
        listResult = result;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    XCTAssertNotNil(listResult);
    NSString* listResultName = listResult.name;
    NSString* expectListResultName = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
    XCTAssert([listResultName isEqualToString:expectListResultName]);
    XCTAssertNotNil(listResult.contents);
}

- (void) testGetBucketACL {
    QCloudGetBucketACLRequest* getBucketACl   = [QCloudGetBucketACLRequest new];
    getBucketACl.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    __block QCloudACLPolicy* policy;
    [getBucketACl setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
        policy = result;
        [exp fulfill];
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucketACL:getBucketACl];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(policy);
    XCTAssert([policy.owner.identifier isEqualToString:[NSString identifierStringWithID:@"2779643970" :@"2779643970"]]);
    XCTAssert([[policy.accessControlList firstObject].grantee.identifier isEqualToString:[NSString identifierStringWithID:@"2779643970":@"2779643970"]]);
}

- (void) testPutBucketCORS {
    QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
    QCloudCORSConfiguration* cors = [QCloudCORSConfiguration new];
    
    QCloudCORSRule* rule = [QCloudCORSRule new];
    rule.identifier = @"sdk";
    rule.allowedHeader = @[@"origin",@"host",@"accept",@"content-type",@"authorization"];
    rule.exposeHeader = @"ETag";
    rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
    rule.maxAgeSeconds = 3600;
    rule.allowedOrigin = @"*";
    
    cors.rules = @[rule];
    
    putCORS.corsConfiguration = cors;
    putCORS.bucket = self.bucket;
    __block NSError* localError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [putCORS setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(localError);
}

- (void) testGetBucketCORS {
    
    QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
    QCloudCORSConfiguration* putCors = [QCloudCORSConfiguration new];
    
    QCloudCORSRule* rule = [QCloudCORSRule new];
    rule.identifier = @"sdk";
    rule.allowedHeader = @[@"origin",@"accept",@"content-type",@"authorization"];
    rule.exposeHeader = @"ETag";
    rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
    rule.maxAgeSeconds = 3600;
    rule.allowedOrigin = @"*";
    
    putCors.rules = @[rule];
    
    putCORS.corsConfiguration = putCors;
    putCORS.bucket = self.bucket;
    __block NSError* localError1;
    
    
    __block QCloudCORSConfiguration* cors;
    __block XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    
    
    [putCORS setFinishBlock:^(id outputObject, NSError *error) {
        
        
        
        QCloudGetBucketCORSRequest* corsReqeust = [QCloudGetBucketCORSRequest new];
        corsReqeust.bucket = self.bucket;
        
        [corsReqeust setFinishBlock:^(QCloudCORSConfiguration * _Nonnull result, NSError * _Nonnull error) {
            cors = result;
            [exp fulfill];
        }];
        
        [[QCloudCOSXMLService defaultCOSXML] GetBucketCORS:corsReqeust];

        
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(cors);
    XCTAssert([[[cors.rules firstObject] identifier] isEqualToString:@"sdk"]);
    XCTAssertEqual(1, cors.rules.count);
    XCTAssertEqual([cors.rules.firstObject.allowedMethod count], 5);
    XCTAssert([cors.rules.firstObject.allowedMethod containsObject:@"PUT"]);
    XCTAssert([cors.rules.firstObject.allowedHeader count] == 4);
    XCTAssert([cors.rules.firstObject.exposeHeader isEqualToString:@"ETag"]);
}

- (void) testGetBucketLocation {
    QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
    locationReq.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"delete"];
    __block QCloudBucketLocationConstraint* location;
    
    
    [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
        location = result;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNotNil(location);
    NSString* currentLocation;
    currentLocation = @"cn-north";
    XCTAssert([location.locationConstraint isEqualToString:currentLocation]);
}

- (void) testPutBucketACL {
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", @"2779643970", @"2779643970"];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    putACL.grantFullControl = grantString;
    putACL.grantRead = grantString;
    putACL.grantWrite = grantString;
    putACL.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    __block NSError* localError;
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    [self waitForExpectationsWithTimeout:100 handler:nil];
    XCTAssertNil(localError);

}



- (void) testPutBucketTagging {
    QCloudPutBucketTaggingRequest* putTagging = [QCloudPutBucketTaggingRequest new];
    QCloudBucketTagging* tagging = [QCloudBucketTagging new];
    QCloudBucketTag* tag = [QCloudBucketTag new];
    tag.key = @"a";
    tag.value = @"b";
    tagging.tagset = @[tag];
    
    putTagging.bucket = self.bucket;
    putTagging.taggings = tagging;
    __block NSError* localError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [putTagging setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketTagging:putTagging];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(localError);
}



- (void)testGetBucketTagging {
    QCloudGetBucketTaggingRequest* request = [QCloudGetBucketTaggingRequest new];
    request.bucket = self.bucket ;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    __block NSError* resultError;
    [request setFinishBlock:^(QCloudBucketTagging* result, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketTagging:request];
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(resultError);
}

- (void)testHeadBucket {
    QCloudHeadBucketRequest* request = [QCloudHeadBucketRequest new];
    request.bucket = self.bucket;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    __block NSError* resultError;
    [request setFinishBlock:^(id outputObject, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] HeadBucket:request];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(resultError);
}


- (void)testDeleteBucketTagging {
    QCloudDeleteBucketTaggingRequest* request = [QCloudDeleteBucketTaggingRequest new];
    request.bucket = self.bucket;
    __block NSError* resultError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [request setFinishBlock:^(id outputObject, NSError* error) {
        resultError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketTagging:request];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertNil(resultError);
}



- (void) testDeleteBucketCORS {
    QCloudDeleteBucketCORSRequest* deleteCORS = [QCloudDeleteBucketCORSRequest new];
    deleteCORS.bucket = self.bucket;
    __block NSError* localError;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [deleteCORS setFinishBlock:^(id outputObject, NSError *error) {
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketCORS:deleteCORS];
    [self waitForExpectationsWithTimeout:80 handler:nil];
    XCTAssertNil(localError);
}



- (void) testListBucketUploads {
    QCloudListBucketMultipartUploadsRequest* uploads = [QCloudListBucketMultipartUploadsRequest new];
    uploads.bucket = self.bucket;
    uploads.maxUploads = 1000;
    __block NSError* localError;
    __block QCloudListMultipartUploadsResult* multiPartUploadsResult;
    XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
    [uploads setFinishBlock:^(QCloudListMultipartUploadsResult* result, NSError *error) {
        multiPartUploadsResult = result;
        localError = error;
        [exp fulfill];
    }];
    [[QCloudCOSXMLService defaultCOSXML] ListBucketMultipartUploads:uploads];
    [self waitForExpectationsWithTimeout:20 handler:nil];
    
    XCTAssertNil(localError);
    XCTAssert(multiPartUploadsResult.maxUploads==1000);
    NSString* expectedBucketString = [NSString stringWithFormat:@"%@-%@",self.bucket,self.appID];
    XCTAssert([multiPartUploadsResult.bucket isEqualToString:expectedBucketString]);
    XCTAssert(multiPartUploadsResult.maxUploads == 1000);
    if (multiPartUploadsResult.uploads.count) {
        QCloudListMultipartUploadContent* firstContent = [multiPartUploadsResult.uploads firstObject];
        XCTAssert([firstContent.owner.displayName isEqualToString:@"2779643970"]);
        XCTAssert([firstContent.initiator.displayName isEqualToString:@"2779643970"]);
        XCTAssertNotNil(firstContent.uploadID);
        XCTAssertNotNil(firstContent.key);
    }
    XCTAssertNotNil(multiPartUploadsResult.delimiter);
}


@end
