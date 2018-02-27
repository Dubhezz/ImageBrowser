//
//  DTZoomAnimationCoordinator.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTZoomAnimationCoordinator : UIPresentationController

@property (nonatomic, weak) UIView *currentHiddenView;
@property (nonatomic, strong) UIView *maskView;

- (void)updateCurrentHiddenView:(UIView *)view;

@end
