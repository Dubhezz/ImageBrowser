//
//  DTImageView.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/5.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DTImageView()

@property (nonatomic, strong) UIImage *presentationImage;

@end

@implementation DTImageView

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
    
    if (!self.presentationImage || !self.placeholderImage) {
        return;
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.presentationImage)
    {
        CGSize size = CGSizeMake(self.presentationImage.size.width * self.presentationImage.scale / [UIScreen mainScreen].scale, self.presentationImage.size.height * self.presentationImage.scale / [UIScreen mainScreen].scale);
        CGRect rect = CGRectMake(0, 0, size.width, size.height);//[LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];
        self.imageView.frame = rect;
    } else {
        CGSize size = CGSizeMake(self.placeholderImage.size.width * self.placeholderImage.scale / [UIScreen mainScreen].scale, self.placeholderImage.size.height * self.placeholderImage.scale / [UIScreen mainScreen].scale);
        CGRect rect = CGRectMake(0, 0, size.width, size.height);//[LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];
        self.imageView.frame = rect;
    }
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:imageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(DTImageViewImageLoading:progress:)]) {
                [self.delegate DTImageViewImageLoading:self progress:receivedSize/(CGFloat)expectedSize];
            }
        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            self.imageView.image = image;
            self.presentationImage = image;
            [self layoutImageView];
            if ([self.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                [self.delegate DTImageViewImageDidLoad:image progress:1];
            }
        }
    }];
}

@end
