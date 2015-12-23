//
//  BYTShadowView.m
//  二维码扫描界面view
//
//  Created by Pikdays on 15/12/23.
//  Copyright (c) 2015年 Pikdays. All rights reserved.
//

#import "BYTShadowView.h"
#import <QuartzCore/QuartzCore.h>


#define AreaRectLineWidth 0.8

@interface BYTShadowView () {
    CGPoint _startPoint;
    CGPoint _endPoint;
}

@property(nonatomic, assign) CGRect clearAreaRect;

@property(nonatomic, strong) UIImageView *scanLineImageView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation BYTShadowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
        [self setupView];
    }

    return self;
}

#pragma mark - ⊂((・猿・))⊃ Override

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationStop) object:nil];
}

- (void)drawRect:(CGRect)rect {
    [self points_Init];

    [self drawScanArea:&rect];
}

- (void)drawScanArea:(CGRect *)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:*rect]; // view的默认颜色
    CGContextClearRect(ctx, _clearAreaRect); // 透明区域
    [self addWhiteRect:ctx rect:_clearAreaRect]; // 绘制透明区域的白色边线
    [self addCornerLineWithContext:ctx rect:_clearAreaRect]; // 四个绿角
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 40 / 255.0, 40 / 255.0, 40 / 255.0, 0.5);
//    [[UIColor lightGrayColor]  setFill];
    CGContextFillRect(ctx, rect);
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    // 博客: http://blog.csdn.net/fhbystudy/article/details/6792891

    CGContextStrokeRect(ctx, rect); // 指定矩形
    CGContextSetLineWidth(ctx, AreaRectLineWidth); // 设置线的宽度
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1); // 画笔颜色设置
    CGContextAddRect(ctx, rect); // 画一方框
    CGContextStrokePath(ctx); // 来描线,即形状
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect {
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83 / 255.0, 239 / 255.0, 111 / 255.0, 1.0);//绿色

    // 左上角
    CGPoint pointsTopLeftA[] = {CGPointMake(rect.origin.x + AreaRectLineWidth, rect.origin.y), CGPointMake(rect.origin.x + AreaRectLineWidth, rect.origin.y + 15)};
    CGPoint pointsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + AreaRectLineWidth), CGPointMake(rect.origin.x + 15, rect.origin.y + AreaRectLineWidth)};
    [self addLine:pointsTopLeftA pointB:pointsTopLeftB ctx:ctx];

    // 左下角
    CGPoint pointsBottomLeftA[] = {CGPointMake(rect.origin.x + AreaRectLineWidth, rect.origin.y + rect.size.height - 15), CGPointMake(rect.origin.x + AreaRectLineWidth, rect.origin.y + rect.size.height)};
    CGPoint pointsBottomLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - AreaRectLineWidth), CGPointMake(rect.origin.x + AreaRectLineWidth + 15, rect.origin.y + rect.size.height - AreaRectLineWidth)};
    [self addLine:pointsBottomLeftA pointB:pointsBottomLeftB ctx:ctx];

    // 右上角
    CGPoint pointsTopRightA[] = {CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + AreaRectLineWidth), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + AreaRectLineWidth)};
    CGPoint pointsTopRightB[] = {CGPointMake(rect.origin.x + rect.size.width - AreaRectLineWidth, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width - AreaRectLineWidth, rect.origin.y + 15 + AreaRectLineWidth)};
    [self addLine:pointsTopRightA pointB:pointsTopRightB ctx:ctx];

    // 右下角
    CGPoint pointsBottomRightA[] = {CGPointMake(rect.origin.x + rect.size.width - AreaRectLineWidth, rect.origin.y + rect.size.height + -15), CGPointMake(rect.origin.x - AreaRectLineWidth + rect.size.width, rect.origin.y + rect.size.height)};
    CGPoint pointsBottomRightB[] = {CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + rect.size.height - AreaRectLineWidth), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - AreaRectLineWidth)};
    [self addLine:pointsBottomRightA pointB:pointsBottomRightB ctx:ctx];

    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

#pragma mark - ⊂((・猿・))⊃ SetupData

- (void)setupData {
    self.scanAreaSize = CGSizeMake(200, 200); // 当做默认
}

#pragma mark - ⊂((・猿・))⊃ SetupView

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];

    [self addSubview:self.scanLineImageView];
    self.scanLineImageView.hidden = YES;

    [self addSubview:self.activityIndicatorView];
}

#pragma mark - ⊂((・猿・))⊃ Set_Get

- (UIImageView *)scanLineImageView {
    if (_scanLineImageView == nil) {
        _scanLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan"]];
    }
    return _scanLineImageView;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = self.center;
    }

    return _activityIndicatorView;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self points_Init];
}

- (void)setScanAreaSize:(CGSize)scanAreaSize {
    _scanAreaSize = scanAreaSize;

    [self points_Init];
}

// 改变frame时候更新下 起点和重点位置
- (void)points_Init {
    // 放在中心位置
    _clearAreaRect = CGRectMake((self.frame.size.width - self.scanAreaSize.width) / 2, (self.frame.size.height - self.scanAreaSize.height) / 2, self.scanAreaSize.width, self.scanAreaSize.height);

    _startPoint = CGPointMake(_clearAreaRect.origin.x + _clearAreaRect.size.width / 2.0, _clearAreaRect.origin.y);
    _endPoint = CGPointMake(_clearAreaRect.origin.x + _clearAreaRect.size.width / 2.0, _clearAreaRect.origin.y + _clearAreaRect.size.height);
}

#pragma mark - ⊂((・猿・))⊃ Action

- (void)showActivityIndicatorView {
    [self.activityIndicatorView startAnimating];
    [self performSelector:@selector(animationStop) withObject:self afterDelay:0.01];
}

- (void)hideActivityIndicatorView {
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Animate

- (void)animationStart {
    self.scanLineImageView.hidden = NO;
    [self animationFromPoint:_startPoint toPoint:_endPoint];
}

- (void)animationStop {
    self.scanLineImageView.hidden = YES;
    [self.scanLineImageView.layer removeAllAnimations];
}

- (void)animationFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.values = @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2]];
    animation.duration = 2;
    animation.repeatCount = MAXFLOAT;
    [self.scanLineImageView.layer addAnimation:animation forKey:nil];
}

@end

