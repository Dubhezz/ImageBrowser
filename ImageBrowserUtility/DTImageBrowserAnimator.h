//
//  DTImageBrowserAnimator.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTImageBrowserAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIView *startView;
@property (nonatomic, strong) UIView *endView;
@property (nonatomic, strong) UIView *zoomView;

- (instancetype)initWithStartView:(UIView *)startView endView:(UIView *)endView zoomView:(UIView *)zoomView;

@end
