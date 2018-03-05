//
//  ViewController.h
//  ImageBrowser
//
//  Created by dubhe on 2018/2/27.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTSmallImageView : UIImageView

@property (nonatomic, copy) void (^imageViewDidTapBlock)(NSUInteger index);
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSURL *imageURL;
- (void)loadImageWithImageURL:(NSURL *)URL;

@end

@interface ViewController : UIViewController


@end

