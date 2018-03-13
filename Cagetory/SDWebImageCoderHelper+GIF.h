//
//  SDWebImageCoderHelper+GIF.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/12.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "SDWebImageCoderHelper.h"

@interface SDWebImageCoderHelper (GIF)

+ (UIImage *)animatedImageWithFrames:(NSArray<SDWebImageFrame *> *)frames;

@end
