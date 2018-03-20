//
//  TACStorageDemoViewController.m
//  TACSamples
//
//  Created by Dong Zhao on 2017/12/5.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TACStorageDemoViewController.h"
#import <QCloudCore/QCloudCore.h>
#import <TACStorage/TACStorage.h>
#import <Photos/Photos.h>
@interface TACStorageDemoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, QCloudCredentailFenceQueueDelegate>
@property (nonatomic, strong) IBOutlet UIImageView* previewImageView;
@property (nonatomic, strong) IBOutlet UIButton* uploadButton;
@property (nonatomic, strong) IBOutlet UIButton* pauseUploadButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelUploadButton;
@property (nonatomic, strong) IBOutlet UIButton* resumeUploadButton;
@property (nonatomic, strong) IBOutlet UIProgressView* uploadProgressView;

@property (nonatomic, strong) IBOutlet UIButton* downloadButton;
@property (nonatomic, strong) IBOutlet UIButton* pauseDownloadButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelDownloadButton;
@property (nonatomic, strong) IBOutlet UIButton* resumeDownloadButton;
@property (nonatomic, strong) IBOutlet UIProgressView* downloadProgressView;

@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
//
@property (nonatomic, strong) NSString* tempFilePath;
//
@property (nonatomic, strong) TACStorageUploadTask* uploadTask;
@property (nonatomic, strong) TACStorageDownloadTask* downloadTask;
@property (nonatomic, strong) TACStorageReference* reference;
@property (nonatomic, strong) UIImagePickerController* pickerController;
@end

@implementation TACStorageDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"从相册选择" style:UIBarButtonItemStyleDone target:self action:@selector(seletImage)];
    self.navigationItem.rightBarButtonItem= item;
    //
    [TACStorageService defaultStorage].credentailFenceQueue.delegate = self;
    self.reference = [[TACStorageService defaultStorage] referenceWithPath:@"test-file/test.png"];
    self.downloadButton.enabled = YES;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = [NSString stringWithFormat:@"https://tac.cloud.tencent.com/client/sts?bucket=tac-demo-storage-1253653367"];
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
            crendential.experationDate = [NSDate dateWithTimeIntervalSince1970:[response[@"expiredTime"] longValue]];
            crendential.token = response[@"credentials"][@"sessionToken"];;
            QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:crendential];
            continueBlock(creator, nil);
        }
    };
    
    [request setFinishBlock:NetworkCall];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];

    //network_request_for_credential
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark selete image
- (void) seletImage
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        UIImagePickerController* picker = self.pickerController;
        [self.navigationController presentViewController:picker animated:YES completion:^{
            
        }];
        return ;
    }
    
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
      
            }
        }];
    }

   
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    self.previewImageView.image = image;
    //
    NSString* tempFilePath = QCloudTempFilePathWithExtension(@"png");
    [UIImagePNGRepresentation(image) writeToFile:tempFilePath atomically:YES];
    self.tempFilePath = tempFilePath;
    self.uploadButton.enabled = YES;
    //
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark upload
- (IBAction)beginUpload:(id)sender
{
    __weak typeof(self) weakSelf = self;
    self.uploadTask = [self.reference putFile:[NSURL fileURLWithPath:self.tempFilePath] metaData:nil completion:^(TACStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error.code != QCloudNetworkErrorCodeCanceled) {
            TACLogInfo(@"上传结果:%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.resumeUploadButton.enabled =
                weakSelf.pauseUploadButton.enabled =
                weakSelf.cancelUploadButton.enabled = NO;
                weakSelf.downloadButton.enabled = YES;
                weakSelf.deleteButton.enabled = YES;
                weakSelf.uploadTask = nil;
            });
        }
    }];
    
    [self.uploadTask observeStatus:TACStorageTaskStatusProgress handler:^(TACStorageTaskSnapshot *snapshot) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.uploadProgressView.progress = snapshot.progress.fractionCompleted;
        });
    }];
    
    
    [self.uploadTask enqueue];
    self.pauseUploadButton.enabled = self.cancelUploadButton.enabled = YES;
    self.resumeUploadButton.enabled = NO;
}

- (IBAction)pauseUpload:(id)sender
{
    if (self.uploadTask.snapshot.status == TACStorageTaskStatusProgress) {
        [self.uploadTask pause];
        self.resumeUploadButton.enabled = YES;
        self.pauseUploadButton.enabled = NO;
    }
}
- (IBAction)resumeUpload:(id)sender
{
    if (self.uploadTask.snapshot.status == TACStorageTaskStatusPause) {
        [self.uploadTask resume];
        self.resumeUploadButton.enabled = NO;
        self.pauseUploadButton.enabled = YES;
    }
}
- (IBAction)cancelUpload:(id)sender
{
    [self.uploadTask cancel];
    self.uploadTask = nil;
}

#pragma mark download

- (IBAction)beginDownload:(id)sender
{
    NSURL* tempFile = [NSURL fileURLWithPath:QCloudTempFilePathWithExtension(@"png")];
    __weak typeof(self) weakSelf = self;
    TACStorageDownloadTask* downloadTask = [self.reference downloadToFile:tempFile completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        weakSelf.downloadTask = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.pauseDownloadButton.enabled = weakSelf.resumeDownloadButton.enabled = weakSelf.cancelDownloadButton.enabled =  NO;
        });
    }];
    
    [downloadTask observeStatus:TACStorageTaskStatusProgress handler:^(TACStorageTaskSnapshot *snapshot) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.downloadProgressView.progress = snapshot.progress.fractionCompleted;
        });
    }];
    
    self.pauseDownloadButton.enabled = YES;
    self.cancelDownloadButton.enabled = YES;
    [downloadTask enqueue];
    self.downloadTask = downloadTask;
}

- (IBAction)pauseDownload:(id)sender
{
    if (self.downloadTask.snapshot.status == TACStorageTaskStatusProgress) {
        [self.downloadTask pause];
        self.pauseUploadButton.enabled = NO;
        self.resumeDownloadButton.enabled = YES;
    }
}

- (IBAction)resumeDownload:(id)sender
{
    if (self.downloadTask.snapshot.status == TACStorageTaskStatusPause) {
        [self.downloadTask resume];
        self.pauseUploadButton.enabled = YES;
        self.resumeDownloadButton.enabled = NO;
    }
}

- (IBAction)cancelDownload:(id)sender
{
    [self.downloadTask cancel];
}

#pragma mark delete
- (IBAction)deleteObject:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self.reference deleteWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            TACLogError(@"删除%@",error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.deleteButton.enabled = NO;
            });
        }
    }];
}

- (UIImagePickerController*)pickerController {
    if (!_pickerController) {
        _pickerController = [[UIImagePickerController alloc] init];
        _pickerController.delegate = self;
        _pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _pickerController;
}
@end
