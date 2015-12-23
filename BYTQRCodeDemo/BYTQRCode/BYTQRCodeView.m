//
//  BYTQRCodeView.m
//  扫描二维码、条形码
//
//  Created by Pikdays on 15/12/23.
//  Copyright (c) 2015年 Pikdays. All rights reserved.
//

#import "BYTQRCodeView.h"
#import "BYTShadowView.h"
#import <AVFoundation/AVFoundation.h>

@interface BYTQRCodeView () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureSession *_session;
    ScanType _currentScanType;
}

@property(nonatomic, copy) ScanSuccessBlock scanSuccess;
@property(nonatomic, copy) ScanFailedBlock scanFailed;

@property(nonatomic, strong) BYTShadowView *shadowView;

@end

@implementation BYTQRCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
        [self setupView];
    }

    return self;
}

#pragma mark - ⊂((・猿・))⊃ Override

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self.shadowView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

#pragma mark - ⊂((・猿・))⊃ SetupData

- (void)setupData {

}

#pragma mark - ⊂((・猿・))⊃ SetupView

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];

    [self addSubview:self.shadowView];
}

#pragma mark - ⊂((・猿・))⊃ Set_Get

- (BYTShadowView *)shadowView {
    if (_shadowView == nil) {
        _shadowView = [[BYTShadowView alloc] initWithFrame:self.bounds];
        _shadowView.scanAreaSize = CGSizeMake(200, 200);
    }

    return _shadowView;
}

- (void)setScanAreaSize:(CGSize)scanAreaSize {
    _scanAreaSize = scanAreaSize;
    self.shadowView.scanAreaSize = _scanAreaSize;
}

- (BOOL)validateCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
            [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (AVCaptureVideoOrientation)videoOrientationFromCurrentDeviceOrientation:(UIDeviceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIDeviceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIDeviceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIDeviceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
        default:
            break;
    }

    return AVCaptureVideoOrientationPortrait;
}

#pragma mark - ⊂((・猿・))⊃ Action

- (void)startScanWithScanType:(ScanType)scanType succeed:(ScanSuccessBlock)success falied:(ScanFailedBlock)failed {
    _currentScanType = scanType;
    self.scanSuccess = success;
    self.scanFailed = failed;

    [self startScan];
}

- (void)startScan {
    if (![self validateCamera]) {
        if (self.scanFailed) {
            self.scanFailed(@"没有可用的相机");
        }
        return;
    }

    if (_session) {
        [self.shadowView hideActivityIndicatorView];
        [_session stopRunning];
        _session = nil;

        //不是很好的方法： 继续扫描
        if ([self.layer.sublayers[0] isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            [self.layer.sublayers[0] removeFromSuperlayer];
        }
    }

    // 1、获取输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    // 2、根据输入设备创建输入对象
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        if (self.scanFailed) {
            self.scanFailed([error localizedDescription]);
        }
        return;
    }

    // 3、创建输出对象
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    CGPoint clearPoint = self.shadowView.clearAreaRect.origin;
    CGSize clearSize = self.shadowView.clearAreaRect.size;
    //4s 3.5寸屏幕可能有误差
    output.rectOfInterest = CGRectMake(clearPoint.y / self.shadowView.frame.size.height, clearPoint.x / self.shadowView.frame.size.width, clearSize.height / self.shadowView.frame.size.height, clearSize.width / self.shadowView.frame.size.width); // 设置有效扫描区域
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    // 5、创建会话
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh]; // 高质量采集率
    // 6、将输入和输出添加到会话
    [_session addInput:input];
    [_session addOutput:output];

    // 7、设置输出的类型(一定要在输入对象添加到会话里面以后再设置输出类型，否则会报错)
    switch (_currentScanType) {
        case ScanType_QRCode: {
            output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode];
        }
            break;
        case ScanType_Barcode: {
            output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                    AVMetadataObjectTypeCode39Code,
                    AVMetadataObjectTypeCode39Mod43Code,
                    AVMetadataObjectTypeEAN13Code,
                    AVMetadataObjectTypeEAN8Code,
                    AVMetadataObjectTypeCode93Code,
                    AVMetadataObjectTypeCode128Code,
                    AVMetadataObjectTypePDF417Code,
                    AVMetadataObjectTypeInterleaved2of5Code,
                    AVMetadataObjectTypeITF14Code,
            ];
        }
            break;
        case ScanType_Normal: {
            output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                    AVMetadataObjectTypeCode39Code,
                    AVMetadataObjectTypeCode39Mod43Code,
                    AVMetadataObjectTypeEAN13Code,
                    AVMetadataObjectTypeEAN8Code,
                    AVMetadataObjectTypeCode93Code,
                    AVMetadataObjectTypeCode128Code,
                    AVMetadataObjectTypePDF417Code,
                    AVMetadataObjectTypeQRCode,
                    AVMetadataObjectTypeAztecCode,
                    AVMetadataObjectTypeInterleaved2of5Code,
                    AVMetadataObjectTypeITF14Code,
                    AVMetadataObjectTypeDataMatrixCode
            ];
        }
            break;
        default:
            break;
    }

    // 8、设置扫面的预览界面
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 充满要显示的view框的
    layer.frame = self.shadowView.layer.bounds;
    layer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation:[UIDevice currentDevice].orientation]; // iPad横屏时候的适配
//     捕捉输出需要设置
//    AVCaptureConnection *output2VideoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
//    output2VideoConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation:1];
    [self.layer insertSublayer:layer atIndex:0];

    // 9、开始采集数据（由于扫描是一个持久过程）
    [_session startRunning];
    [self.shadowView animationStart];
}

- (void)stopScan {
    [_session stopRunning];
}

#pragma mark - ⊂((・猿・))⊃ Delegate
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 扫描到数据之后会调用这个方法。因为调用非常频繁，所以判断，当捕获到数据之后，立即停止扫描
    if (metadataObjects != nil && metadataObjects.count > 0) {
        // 1、停止扫描
        [_session stopRunning];

        [self.shadowView showActivityIndicatorView];

        // 3、取出数据
        if (self.scanSuccess) {
            AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
            self.scanSuccess(metadataObject.stringValue); // 输出扫描字符串
        }
    }
}

@end
