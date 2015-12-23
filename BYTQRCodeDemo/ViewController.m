//
//  ViewController.m
//  BYTQRCodeDemo
//
//  Created by chengxin on 15/12/23.
//  Copyright © 2015年 Pikdays. All rights reserved.
//


#import "ViewController.h"
#import "BYTQRCode.h"

@interface ViewController () <UIAlertViewDelegate>

@property(nonatomic, strong) BYTQRCodeView *qrCodeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupView];
}

#pragma mark - ⊂((・猿・))⊃ SetupData

- (void)setupData {
    
}

#pragma mark - ⊂((・猿・))⊃ SetupView

- (void)setupView {
    [self.view addSubview:self.qrCodeView];
}

#pragma mark - ⊂((・猿・))⊃ Set_Get

- (BYTQRCodeView *)qrCodeView {
    if (_qrCodeView == nil) {
        _qrCodeView = [[BYTQRCodeView alloc] initWithFrame:self.view.bounds];
        _qrCodeView.scanAreaSize = CGSizeMake(300, 300);
        __weak  ViewController *weakSelf = self;
        [self.qrCodeView startScanWithScanType:ScanType_Normal
                                       succeed:^(NSString *string) {
                                           __strong  ViewController *strongSelf = weakSelf;
                                           [[[UIAlertView alloc] initWithTitle:nil message:string delegate:strongSelf cancelButtonTitle:@"继续扫描" otherButtonTitles:@"OK", nil] show];
                                       }
                                        falied:^(NSString *errorMessage) {
                                            NSLog(@"error: %@", errorMessage);
                                        }];
    }
    
    return _qrCodeView;
}

#pragma mark - ⊂((・猿・))⊃ Delegate
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.qrCodeView startScan];
    } else {
        
    }
}

@end
