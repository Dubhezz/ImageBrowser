//
//  DTImage.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/7.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTImage : UIImage

@property (nonatomic, assign, readonly) NSUInteger loopCount;
@property (nonatomic, readonly) NSTimeInterval *frameDurations;
@property (nonatomic, readonly) NSTimeInterval frameDuration;
@property (nonatomic, readonly) NSTimeInterval totalDuration;
- (UIImage*)getFrameWithIndex:(NSUInteger)idx;

@end
