//
//  DTImageBrowserAnimator.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTImageBrowserAnimator.h"

@implementation DTImageBrowserAnimator

- (instancetype)initWithStartView:(UIView *)startView endView:(UIView *)endView zoomView:(UIView *)zoomView {
    self = [super init];
    if (self) {
        self.startView = startView;
        self.endView = endView;
        self.zoomView = zoomView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!fromVC || !toVC) {
        return;
    }
    BOOL presentation = (toVC == fromVC.presentedViewController);
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    if (!presentation) {
        presentedView.hidden = YES;
    }
    
    UIView *containerView = [transitionContext containerView];
    CGRect startFrame = CGRectZero;
    if (!self.startView || !self.zoomView) {
        return;
    }
    startFrame = [self.startView convertRect:self.startView.bounds toView:containerView];
    CGRect endFrame = startFrame;
    CGFloat endAlpha = 0.0f;
    if (self.endView) {
        CGRect relativeFrame = [self.endView convertRect:self.endView.bounds toView:nil];
        if (CGRectIntersectsRect([UIScreen mainScreen].bounds, relativeFrame)) {
            endAlpha = 1.0;
            //ipod endframe 计算有误
            endFrame = [self.endView convertRect:self.endView.bounds toView:containerView];
        }
    }
    self.zoomView.frame = startFrame;
    [containerView addSubview:self.zoomView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.zoomView.alpha = endAlpha;
        self.zoomView.frame = endFrame;
    } completion:^(BOOL finished) {
        UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
        if (presentation && presentedView) {
            [containerView addSubview:presentedView];
        }
        [self.zoomView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
