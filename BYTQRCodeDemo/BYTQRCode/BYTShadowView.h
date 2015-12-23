//
//  BYTShadowView.h
//  二维码扫描界面view
//
//  Created by Pikdays on 15/12/23.
//  Copyright (c) 2015年 Pikdays. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYTShadowView : UIView

@property(nonatomic, assign) CGSize scanAreaSize;
@property(nonatomic, assign, readonly) CGRect clearAreaRect;

- (void)animationStart;

- (void)animationStop;

- (void)showActivityIndicatorView;

- (void)hideActivityIndicatorView;

@end


/*
 BYTShadowView *view = [[BYTShadowView alloc]initWithFrame:self.view.bounds];
 [self.view addSubview:view];
 NSLog(@"%@",NSStringFromCGSize(view.scanAreaSize));
 view.scanAreaSize = CGSizeMake(200, 200);
 
 view.backgroundColor = [UIColor clearColor];
 
 self.view.backgroundColor = [UIColor  whiteColor];
 */