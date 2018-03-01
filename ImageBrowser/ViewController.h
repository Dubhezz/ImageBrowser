//
//  ViewController.h
//  ImageBrowser
//
//  Created by dubhe on 2018/2/27.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTImageView;

@protocol DTImageViewDelegate <NSObject>
@optional

- (void)DTImageViewImageLoading:(DTImageView *)imageView progress:(CGFloat)progress;
- (void)DTImageViewImageDidLoad:(UIImage *)image progress:(CGFloat)progress;

@end

@interface DTImageView : UIImageView
@property (nonatomic, weak) id<DTImageViewDelegate> delegate;
@property (nonatomic, copy) void (^imageViewDidTapBlock)(NSUInteger index);
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSURL *imageURL;
- (void)loadImageWithImageURL:(NSURL *)URL;

@end

@interface ViewController : UIViewController


@end

