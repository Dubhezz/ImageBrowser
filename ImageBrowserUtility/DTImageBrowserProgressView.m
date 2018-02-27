//
//  DTImageBrowserProgressView.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/25.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTImageBrowserProgressView.h"

@interface DTImageBrowserProgressView ()

@property (nonatomic, strong) CAShapeLayer *cirecleLayer;
@property (nonatomic, strong) CAShapeLayer *fanshapedLayer;

@end

@implementation DTImageBrowserProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.bounds = CGRectMake(0, 0, 50, 50);
        [self setupUI];
        self.progress = 0.0f;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _fanshapedLayer.path = [self maskProgesssPathWith:progress].CGPath;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    UIColor *strokeColor = [UIColor colorWithWhite:1 alpha:0.8];
    _cirecleLayer = [[CAShapeLayer alloc] init];
    _cirecleLayer.strokeColor = strokeColor.CGColor;
    _cirecleLayer.fillColor = [UIColor clearColor].CGColor;
    _cirecleLayer.path = [self makeCircelPath].CGPath;
    [self.layer addSublayer:_cirecleLayer];
    
    _fanshapedLayer = [[CAShapeLayer alloc] init];
    _fanshapedLayer.fillColor = strokeColor.CGColor;
    [self.layer addSublayer:_fanshapedLayer];
}

- (UIBezierPath *)makeCircelPath {
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:25 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = 2;
    return path;
}

- (UIBezierPath *)maskProgesssPathWith:(CGFloat)progress {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetMidY(self.bounds) - 2.5;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds), center.y - radius)];
    [path addArcWithCenter:center radius:radius startAngle:(CGFloat)- M_PI / 2 endAngle:(CGFloat)- M_PI / 2 + progress * M_PI * 2  clockwise:YES];
    [path closePath];
    path.lineWidth = 1;
    return path;
}

@end
