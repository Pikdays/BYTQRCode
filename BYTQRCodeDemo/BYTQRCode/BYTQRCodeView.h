//
//  BYTQRCodeView.h
//  扫描二维码、条形码
//
//  Created by Pikdays on 15/12/23.
//  Copyright (c) 2015年 Pikdays. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScanType_Normal = 0,
    ScanType_QRCode,
    ScanType_Barcode
} ScanType;

typedef void(^ScanSuccessBlock)(NSString *string);

typedef void(^ScanFailedBlock)(NSString *errorMessage);

@interface BYTQRCodeView : UIView

@property(nonatomic, assign) CGSize scanAreaSize;

- (void)startScan;

- (void)startScanWithScanType:(ScanType)scanType succeed:(ScanSuccessBlock)success falied:(ScanFailedBlock)failed;

@end
