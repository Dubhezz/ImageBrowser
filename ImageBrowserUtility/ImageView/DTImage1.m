//
//  DTImage1.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/12.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTImage1.h"

@interface DTImage1 ()
@property (nonatomic, readwrite) NSMutableArray *images;
@end

@implementation DTImage1 {
    dispatch_queue_t readFrameQueue;
    CGImageSourceRef _imageSourceRef;
    CGFloat _scale;
}
@synthesize images;
static NSUInteger _prefetchedNum = 10;

- (id)initWithData:(NSData *)data
{
    return [self initWithData:data scale:1.0f];
}

- (id)initWithData:(NSData *)data scale:(CGFloat)scale
{
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
    self.images = [NSMutableArray arrayWithCapacity:numberOfFrames];
    NSNull *aNull = [NSNull null];
    for (NSUInteger i = 0; i < numberOfFrames; ++i) {
        [self.images addObject:aNull];
    }
    NSUInteger num = MIN(_prefetchedNum, numberOfFrames);
    for (NSUInteger i=0; i<num; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        if (image != NULL) {
            [self.images replaceObjectAtIndex:i withObject:[UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp]];
            CFRelease(image);
        } else {
            [self.images replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }
    _imageSourceRef = imageSource;
    CFRetain(_imageSourceRef);
    CFRelease(imageSource);
    return self;
}

- (UIImage*)getFrameWithIndex:(NSUInteger)idx {
    UIImage* frame = nil;
    @synchronized(self.images) {
        frame = self.images[idx];
    }
    if(!frame) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSourceRef, idx, NULL);
        if (image != NULL) {
            frame = [UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp];
            CFRelease(image);
        }
    }
    
    if(self.images.count > _prefetchedNum) {
        if(idx != 0) {
            [self.images replaceObjectAtIndex:idx withObject:[NSNull null]];
        }
        NSUInteger nextReadIdx = (idx + _prefetchedNum);
        for(NSUInteger i=idx+1; i<=nextReadIdx; i++) {
            NSUInteger _idx = i%self.images.count;
            if([self.images[_idx] isKindOfClass:[NSNull class]]) {
                dispatch_async(dispatch_queue_create("com.ronnie.gifreadframe", DISPATCH_QUEUE_SERIAL), ^{
                    CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSourceRef, _idx, NULL);
                    @synchronized(self.images) {
                        //                        for (id obj in self.images) {
                        //                            if ([obj isKindOfClass:[UIImage class]]) {
                        //                                NSUInteger index = [self.images indexOfObject:obj];
                        //                                NSLog(@"%ld",index);
                        //                            }
                        //                        }
                        //                        NSLog(@"-------------------------------------------------------------");
                        if (image != NULL) {
                            [self.images replaceObjectAtIndex:_idx withObject:[UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp]];
                            CFRelease(image);
                        } else {
                            [self.images replaceObjectAtIndex:_idx withObject:[NSNull null]];
                        }
                    }
                });
            }
        }
    }
    
    return frame;
}
- (void)dealloc {
    if(_imageSourceRef) {
        CFRelease(_imageSourceRef);
    }
}


@end
