//
//  UIImage+KeyFrames.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/12.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (KeyFrames)

@property (nonatomic, strong) NSMutableArray *tempImages;
@property (nonatomic, assign) NSUInteger index;
- (UIImage*)getFrameWithIndex:(NSUInteger)idx;

@end
