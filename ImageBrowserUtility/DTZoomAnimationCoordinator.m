//
//  DTZoomAnimationCoordinator.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTZoomAnimationCoordinator.h"

@implementation DTZoomAnimationCoordinator

- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

- (void)updateCurrentHiddenView:(UIView *)view {
    self.currentHiddenView.hidden = NO;
    self.currentHiddenView = view;
    view.hidden = YES;
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    UIView *containerView = self.containerView;
    if (!containerView) {
        return;
    }
    [containerView addSubview:self.maskView];
    self.maskView.frame = containerView.bounds;
    self.maskView.alpha = 0;
    self.currentHiddenView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        weakSelf.maskView.alpha = 1;
    } completion:nil];
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    __weak typeof(self) weakSelf = self;
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        weakSelf.maskView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        weakSelf.currentHiddenView.hidden = NO;
    }];
}

@end
