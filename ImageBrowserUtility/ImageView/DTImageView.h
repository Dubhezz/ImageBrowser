//
//  DTImageView.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/5.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTImageView;

@protocol DTImageViewDelegate <NSObject>
@optional

- (void)DTImageViewImageLoading:(DTImageView *)imageView progress:(CGFloat)progress;
- (void)DTImageViewImageDidLoad:(UIImage *)image progress:(CGFloat)progress;

@end

@interface DTImageView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<DTImageViewDelegate> delegate;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong, readonly) UIImage *presentationImage;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong, readonly) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval frameDuration;         //duration between two frames
@property (nonatomic, assign) NSUInteger animationRepeatCount;      //0 is infinity
@property (nonatomic, assign) BOOL isAnimating;                     //indicate animation is playing or not
@property (nonatomic, assign) BOOL shouldAutoPlay;                  //auto play after load mutiple images
@property (nonatomic, assign) NSUInteger frameIndex; 
@property (nonatomic, strong) NSData *gifData;

- (void)loadImageWithImageURL:(NSURL *)URL;

@end
