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

@interface DTImageView()

@property (nonatomic, strong) UIImage *presentationImage;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger animationIndex;
@property (nonatomic, assign) NSUInteger frameIndex;

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
            UIImage *image = [[SDWebImageGIFCoder sharedCoder] decodedImageWithData:data];
            NSString *key = [manager cacheKeyForURL:imageURL];
            weakSlef.imageView.image = image.images[0];
            weakSlef.presentationImage = image;
            [weakSlef layoutImageView];
            if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                [weakSlef resetTimer];
                [weakSlef.delegate DTImageViewImageDidLoad:image.images[0] progress:1];
            }
            [[manager imageCache] storeImage:image forKey:key completion:nil];
        } else if (image) {
            if (image.images.count <= 1) NSLog(@"GIF 解析有误");
            weakSlef.imageView.image = image.images[0];
            weakSlef.presentationImage = image;
            [weakSlef layoutImageView];
            if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                [weakSlef resetTimer];
                [weakSlef.delegate DTImageViewImageDidLoad:image.images[0] progress:1];
            }
        }
    }];
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)resetTimer
{
    [self.timer invalidate];
    self.timer = nil;
    NSTimeInterval frameDuration = self.presentationImage.duration / (self.presentationImage.images.count > 0 ? (CGFloat)(self.presentationImage.images.count) : 1);
    
    if (frameDuration <= 0)
    {
        frameDuration = 1;
    }
    self.animationIndex       = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:frameDuration target:self selector:@selector(handleAnimation) userInfo:nil repeats:YES];
}

- (void)handleAnimation {
    if (self.presentationImage.images.count == 0)
    {
        return;
    }
    self.animationIndex++;
//    if (self.animationIndex < self.presentationImage.images.count)
//    {
        self.frameIndex = self.animationIndex % self.presentationImage.images.count;
//    }
//    else
//    {
//        self.frameIndex = self.presentationImage.images.count - 1;
//    }
    self.imageView.image = self.presentationImage.images[self.frameIndex];
}

@end
