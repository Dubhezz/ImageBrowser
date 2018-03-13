//
//  UIImage+KeyFrames.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/12.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "UIImage+KeyFrames.h"
#import <objc/runtime.h>

static void *tempImagesKey = &tempImagesKey;
static void *imageIndexKey = &imageIndexKey;
static NSUInteger _prefetchedNumber = 10;

@implementation UIImage (KeyFrames)

dispatch_queue_t readFrameQueue;

- (void)setIndex:(NSUInteger)index {
    objc_setAssociatedObject(self, &imageIndexKey, @(index), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)index {
    return [objc_getAssociatedObject(self, &imageIndexKey) integerValue];
}

- (void)setTempImages:(NSMutableArray *)tempImages {
    objc_setAssociatedObject(self, &tempImagesKey, tempImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)tempImages {
    return objc_getAssociatedObject(self, &tempImagesKey);
}

- (UIImage *)getFrameWithIndex:(NSUInteger)index {
    if(index > self.tempImages.count || [self.tempImages[index] isKindOfClass:[NSNull class]]){
        return nil;
    }
    UIImage* frame = nil;
    @synchronized(self.tempImages) {
        frame = self.tempImages[index];
    }
    
    if (!frame) {
        UIImage *image = self.images[index];
        if (image) {
            frame = image;
        }
    }
    
    if(self.tempImages.count > _prefetchedNumber) {
        if(index != 0) {
            [self.tempImages replaceObjectAtIndex:index withObject:[NSNull null]];
        }
        NSUInteger nextReadIndex = (index + _prefetchedNumber);
        for(NSUInteger i = index+1; i<= nextReadIndex; i++) {
            NSUInteger _index = i % self.tempImages.count;
            if([self.tempImages[_index] isKindOfClass:[NSNull class]]) {
                dispatch_async(dispatch_queue_create("com.ronnie.gifreadframe", DISPATCH_QUEUE_SERIAL), ^{
                    UIImage *image = self.images[_index];
                    @synchronized(self.tempImages) {
                        for (id obj in self.tempImages) {
                            if ([obj isKindOfClass:[UIImage class]]) {
                                NSUInteger index = [self.tempImages indexOfObject:obj];
                                NSLog(@"%ld",index);
                            }
                        }
                        NSLog(@"-------------------------------------------------------------");
                        if (image != NULL) {
                            [self.tempImages replaceObjectAtIndex:_index withObject:image];
                        } else {
                            [self.tempImages replaceObjectAtIndex:_index withObject:[NSNull null]];
                        }
                    }
                });
            }
        }
    }
    
    
    return frame;
}

@end
