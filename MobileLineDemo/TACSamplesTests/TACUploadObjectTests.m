//
//  TACUploadObjectTests.m
//  TACSamplesTests
//
//  Created by Dong Zhao on 2017/11/27.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TACStorage/TACStorage.h>

@interface TACUploadObjectTests : XCTestCase <QCloudCredentailFenceQueueDelegate>
@property (nonatomic, strong) NSMutableArray* tempFilePathArray;
@end

@implementation TACUploadObjectTests
- (void) fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
 
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = [NSString stringWithFormat:@"https://tac.cloud.tencent.com/client/sts?bucket=%@",[TACStorageService defaultStorage].rootReference.bucket];
    [request setConfigureBlock:^(QCloudRequestSerializer *requestSerializer, QCloudResponseSerializer *responseSerializer) {
        responseSerializer.serializerBlocks = @[QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), nil], nil),
                                                QCloudResponseJSONSerilizerBlock];
    }];
    void(^NetworkCall)(id response, NSError* error) = ^(id response, NSError* error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudCredential* crendential = [[QCloudCredential alloc] init];
            crendential.secretID = response[@"credentials"][@"tmpSecretId"];
            crendential.secretKey = response[@"credentials"][@"tmpSecretKey"];
            crendential.experationDate = [NSDate dateWithTimeIntervalSinceNow:[response[@"expiredTime"] intValue]];
            crendential.token = response[@"credentials"][@"sessionToken"];;
            QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:crendential];
            continueBlock(creator, nil);
        }
    };
    
    [request setFinishBlock:NetworkCall];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];
    
    //network_request_for_credential
}

- (void)setUp {
    [super setUp];
    [TACStorageService defaultStorage].credentailFenceQueue.delegate = self;
    _tempFilePathArray = [NSMutableArray new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    for (NSString* path in self.tempFilePathArray) {
        QCloudRemoveFileByPath(path);
    }
}

- (NSString*) tempFileWithSize:(int)size
{
    NSString* file4MBPath = QCloudPathJoin(QCloudTempDir(), [NSUUID UUID].UUIDString);
    
    if (!QCloudFileExist(file4MBPath)) {
        [[NSFileManager defaultManager] createFileAtPath:file4MBPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle* handler = [NSFileHandle fileHandleForWritingAtPath:file4MBPath];
    [handler truncateFileAtOffset:size];
    [handler closeFile];
    [self.tempFilePathArray  addObject:file4MBPath];
    return file4MBPath;
}

- (void) testUploadFile4MB
{
    NSString* mb4bfile = [self tempFileWithSize:4*1024*1024];
    
    TACStorageReference* ref = [[TACStorageService defaultStorage] referenceWithPath:@"hello"];
    XCTestExpectation* exp = [self expectationWithDescription:@"xx"];
    
    __block TACStorageMetadata* result;
    TACStorageUploadTask* task = [ref putFile:[NSURL fileURLWithPath:mb4bfile] metaData:nil completion:^(TACStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        result = metadata;
        [exp fulfill];
    }];
    
    [task  observeStatus:TACStorageTaskStatusProgress handler:^(TACStorageTaskSnapshot *snapshot) {
        NSLog(@"progress %f", snapshot.progress.fractionCompleted);
    }];
    
    [task enqueue];
    [self waitForExpectationsWithTimeout:1000 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertNotNil(result);
    XCTAssertNotNil(result.downloadURL);
}

- (void) testDownloadPauseResume
{
    TACStorageReference* ref = [[TACStorageService defaultStorage] referenceWithPath:@"hello"];
    XCTestExpectation* exp = [self expectationWithDescription:@"xx"];
    XCTestExpectation* resumeExp = [self expectationWithDescription:@"resume"];
    NSURL* url =[NSURL URLWithString:QCloudTempFilePathWithExtension(@"temp")];
    
    TACStorageDownloadTask* download = [ref downloadToFile:url completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        [resumeExp fulfill];
    }];
    
    __weak typeof(download) weakDownload = download;
    __block BOOL oncePause = YES;
    [download observeStatus:TACStorageTaskStatusProgress handler:^(TACStorageTaskSnapshot *snapshot) {
        if (snapshot.progress.fractionCompleted > 0.3 && oncePause) {
            oncePause = NO;
            [weakDownload pause];
            [exp fulfill];
        }
        TACLogDebug(@"download progress %f", snapshot.progress.fractionCompleted);
    }];
    [download enqueue];
    [self waitForExpectations:@[exp] timeout:100];

    [download resume];
    
    [self waitForExpectations:@[resumeExp] timeout:100];
    
    XCTAssert(QCloudFileSize(url.path) == 1024*1024*4);
}

- (void) testUploadData
{
    TACStorageReference* ref = [[TACStorageService defaultStorage] rootReference];
    ref = [ref child:@"object-test"];
    
    XCTestExpectation* exp = [self expectationWithDescription:@"puta"];


    NSString* content = @"xxxxx";
    __block TACStorageMetadata* metadataResult = nil;
    TACStorageUploadTask* uploadTask = [ref putData:[content dataUsingEncoding:NSUTF8StringEncoding] metaData:nil completion:^(TACStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        metadataResult = metadata;
        [exp fulfill];
    }];
    [uploadTask enqueue];
    [self waitForExpectationsWithTimeout:100 handler:^(NSError * _Nullable error) {
        
    }];

    XCTAssertNotNil(metadataResult);
    XCTAssertNotNil(metadataResult.downloadURL);
    
    //download file
    NSString* temp = QCloudTempFilePathWithExtension(@".txt");
    XCTestExpectation* exp2 = [self expectationWithDescription:@"download"];
    NSURL* fileURL = [NSURL fileURLWithPath:temp];
    TACStorageDownloadTask* dt = [ref downloadToFile:fileURL completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        [exp2 fulfill];
    }];
    [dt enqueue];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        
    }];
    
    NSString* downloadData = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:fileURL] encoding:NSUTF8StringEncoding];
    XCTAssert([content isEqualToString:downloadData]);
}

@end
