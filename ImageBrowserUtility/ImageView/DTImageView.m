//
//  DTImageView.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/5.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+GIF.h>
#import <SDWebImage/SDWebImageCodersManager.h>
#import <SDWebImage/NSData+ImageContentType.h>
#import <SDWebImage/SDWebImageGIFCoder.h>
#import "DTImage.h"

@interface DTImageView()

@property (nonatomic, strong) UIImage *presentationImage;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger animationIndex;

@property (nonatomic, strong) DTImage *animatedImage;

@end

@implementation DTImageView

- (void)dealloc {
    
    NSLog(@"View释放");
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.imageView                   = [[UIImageView alloc] init];
    self.imageView.backgroundColor   = [UIColor clearColor];
    self.imageView.clipsToBounds     = YES;
    [self addSubview:self.imageView];
    self.clipsToBounds     = YES;
    self.opaque            = YES;
    self.layer.opaque      = YES;
    self.backgroundColor   = [UIColor clearColor];
    self.shouldAutoPlay    = YES;
}

- (void)layoutImageView {
    
    if (!self.presentationImage && !self.placeholderImage) {
        return;
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    CGRect bounds = self.bounds;
    if (self.presentationImage)
    {
        CGSize size = CGSizeMake(self.presentationImage.size.width * self.presentationImage.scale / [UIScreen mainScreen].scale, self.presentationImage.size.height * self.presentationImage.scale / [UIScreen mainScreen].scale);
        CGPoint point = CGPointMake((bounds.size.width - size.width) / 2, (bounds.size.height - size.height) / 2);
        CGRect rect = (CGRect){
            point,
            size
        };//[LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];
        self.imageView.frame = bounds;
    } else {
        CGSize size = CGSizeMake(self.placeholderImage.size.width * self.placeholderImage.scale / [UIScreen mainScreen].scale, self.placeholderImage.size.height * self.placeholderImage.scale / [UIScreen mainScreen].scale);
        CGPoint point = CGPointMake((bounds.size.width - size.width) / 2, (bounds.size.height - size.height) / 2);
        CGRect rect = (CGRect){
            point,
            size
        };//[LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];
        self.imageView.frame = bounds;
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    self.imageView.image = placeholderImage;
    [self layoutImageView];
}

- (void)setImageURL:(NSURL *)imageURL {
    __weak typeof(self) weakSlef  = self;
    _imageURL = imageURL;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    if (![[[SDWebImageCodersManager sharedInstance] coders] containsObject:[SDWebImageGIFCoder sharedCoder]]) {
        [[SDWebImageCodersManager sharedInstance] addCoder:[SDWebImageGIFCoder sharedCoder]];
    }
    [manager loadImageWithURL:imageURL options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageLoading:progress:)] && [imageURL.absoluteString isEqualToString:targetURL.absoluteString]) {
                [weakSlef.delegate DTImageViewImageLoading:weakSlef progress:receivedSize/(CGFloat)expectedSize];
            }
        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if ([NSData sd_imageFormatForImageData:data] == SDImageFormatGIF) {
#warning 此处直接加载动图会造成内存暴增
            DTImage *dtImage = [[DTImage alloc] initWithData:data];
            weakSlef.animatedImage = dtImage;
            
            UIImage *image = [[SDWebImageGIFCoder sharedCoder] decodedImageWithData:data];
            NSString *key = [manager cacheKeyForURL:imageURL];
//            weakSlef.imageView.image = image.images[0];
//            weakSlef.presentationImage = image;
//            [weakSlef layoutImageView];
             [weakSlef internalSetImage:image];
            self.gifData = data;
            if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                [weakSlef.delegate DTImageViewImageDidLoad:image.images[0] progress:1];
            }
//            [[manager imageCache] storeImage:image forKey:key completion:nil];
            //view
        } else if (image) {
            if ([imageURL.absoluteString hasSuffix:@".gif"]) {
                dispatch_async(dispatch_queue_create("GIFEncoder_Queue", DISPATCH_QUEUE_CONCURRENT), ^{
                    NSData *data = [[SDWebImageGIFCoder sharedCoder] encodedDataWithImage:image format:SDImageFormatGIF];
                    DTImage *dtImage = [[DTImage alloc] initWithData:data];
                    weakSlef.animatedImage = dtImage;
                    self.gifData = data;
                    [weakSlef internalSetImage:image];
                    if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                        [weakSlef.delegate DTImageViewImageDidLoad:image.images[0] progress:1];
                    }
                });
            } else {
                [weakSlef internalSetImage:image];
                if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                    [weakSlef.delegate DTImageViewImageDidLoad:image.images[0] progress:1];
                }
            }
//            if (image.images.count <= 1) NSLog(@"GIF 解析有误");
//            weakSlef.imageView.image = image.images[0];
//            weakSlef.presentationImage = image;
//            [weakSlef layoutImageView];
            ;
            
        }
    }];
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
    [super layoutSubviews];
}

- (UIImage *)loadAnimatedGIFWith:(NSData *)data {
    if (!data) {
        return nil;
    }
    //类型转换
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    //几张图片
    size_t count = CGImageSourceGetCount(source);
    //返回的变量
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        //取出gif中的单张图片
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, _animationIndex % count, NULL);
        _animationIndex ++;
        //类型的转换
        animatedImage = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        
        CGImageRelease(image);
    }
    CFRelease(source);
    return animatedImage;
}

- (void)internalSetImage:(UIImage *)image {
    _presentationImage = image;
    self.animationIndex = 0;
    if (image.images.count > 1) {
        self.imageView.image = image.images.firstObject;
        self.imageView.animationImages = image.images;
    } else {
        self.imageView.image = image;
        self.isAnimating = false;
    }
    if (self.shouldAutoPlay && image.images.count > 1) {
        self.isAnimating = true;
    }
    if (image) {
        [self layoutImageView];
    }
}

- (void)setIsAnimating:(BOOL)isAnimating {
    if (_isAnimating == isAnimating) {
        return;
    }
    if (self.presentationImage.images.count <= 1) {
        return;
    }
    _isAnimating = isAnimating;
    if (isAnimating) {
        [self resetTimer];
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setShouldAutoPlay:(BOOL)shouldAutoPlay {
    _shouldAutoPlay = shouldAutoPlay;
    if (shouldAutoPlay)
    {
        self.isAnimating = YES;
    }
}

- (void)resetTimer
{
    [self.timer invalidate];
    self.timer = nil;
    if (!self.isAnimating)
    {
        return;
    }
    NSTimeInterval frameDuration = (self.animatedImage.totalDuration / self.animatedImage.images.count) > 0 ? (self.animatedImage.totalDuration / self.animatedImage.images.count) : (1 / 30.0); //self.presentationImage.duration / (self.presentationImage.images.count > 0 ? (CGFloat)(self.presentationImage.images.count) : 1);
    
    if (frameDuration <= 0)
    {
        frameDuration = 1;
    }
    self.animationIndex       = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:frameDuration target:self selector:@selector(handleAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)setFrameDuration:(NSTimeInterval)frameDuration {
    _frameDuration = frameDuration;
    [self resetTimer];
}


- (void)handleAnimation {
    if (self.presentationImage.images.count == 0)
    {
        return;
    }
   
    self.animationIndex++;
    if (self.animationRepeatCount == 0 || self.animationIndex < self.animationRepeatCount * self.presentationImage.images.count)
    {
         self.frameIndex = self.animationIndex % self.animatedImage.images.count;
//        self.frameIndex = self.animationIndex % self.presentationImage.images.count;
    }
    else
    {
        self.frameIndex = self.animatedImage.images.count - 1;
    }
    UIImage *image = [self.animatedImage getFrameWithIndex:self.frameIndex];
    if ([image isKindOfClass:[UIImage class]]) {
        self.imageView.image = image;
    }
//    self.imageView.image = self.presentationImage.images[self.frameIndex]; //这样会造成内存暴增
}

@end
