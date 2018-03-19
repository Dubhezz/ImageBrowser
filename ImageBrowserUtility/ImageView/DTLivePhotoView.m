//
//  DTLivePhotoView.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/16.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTLivePhotoView.h"
#import "DTLivePhotoDownLoadManager.h"

@interface DTLivePhotoView () <PHLivePhotoViewDelegate>

@property (nonatomic, strong) PHLivePhoto *livephoto;

@end

@implementation DTLivePhotoView

- (void)dealloc {
    NSLog(@"LivephotoView 释放");
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
    self.livePhotoView = [[PHLivePhotoView alloc] init];
    self.livePhotoView.delegate = self;
    self.thumbnailImageView = [[UIImageView alloc] init];
    [self addSubview:self.thumbnailImageView];
    [self addSubview:self.livePhotoView];
}

- (void)layoutLivephotoView {
    if (!self.livePhotoView && !self.placeholderImage) {
        return;
    }
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    CGRect bounds = self.bounds;
    if (self.livephoto)
    {
        CGSize size = CGSizeMake(self.livephoto.size.width, self.livephoto.size.height);
        CGPoint point = CGPointMake((bounds.size.width - size.width) / 2, (bounds.size.height - size.height) / 2);
        CGRect rect = (CGRect){
            point,
            size
        };//[LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];
        self.livePhotoView.frame = bounds;
    } else {
        CGSize size = CGSizeMake(self.placeholderImage.size.width * self.placeholderImage.scale / [UIScreen mainScreen].scale, self.placeholderImage.size.height * self.placeholderImage.scale / [UIScreen mainScreen].scale);
        CGPoint point = CGPointMake((bounds.size.width - size.width) / 2, (bounds.size.height - size.height) / 2);
        CGRect rect = (CGRect){
            point,
            size
        };//[LKImageUtil rectFromClipSize:size clipSize:self.bounds.size scaleMode:self.scaleMode anchorPoint:self.anchorPoint];
        self.thumbnailImageView.frame = bounds;
    }
}

- (void)layoutSubviews {
    self.livePhotoView.frame = self.bounds;
    self.thumbnailImageView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    self.thumbnailImageView.image = placeholderImage;
    [self layoutLivephotoView];
}

- (void)loadImageWithVideoURLString:(NSString *)videoURLString imageURLString:(NSString *)imageURLString targetSize:(CGSize)size completion:(DTLivephotoViewDidLoadImageCompletion)completion {
    __weak typeof(self) weakSelf = self;
    [[[DTLivePhotoDownLoadManager alloc] init] downloadeVideoWithVideoURLString:videoURLString imageURLString:imageURLString mergeProgress:^(NSURL *videoURL, float progress) {
        NSLog(@"---- %@ -----", @(progress));
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(DTLivephotoViewImageLoading:targetVideoURL:progress:)]) {
                [self.delegate DTLivephotoViewImageLoading:self targetVideoURL:videoURL progress:progress];
            }
        });
    } callBack:^(NSString * _Nullable videoFilePath, NSString * _Nullable imageFilePath, NSError * _Nullable error) {
        if (error) {
            NSLog(@"livePhoto 生成错误 ----- %@", error);
        } else {
            if ([self.delegate respondsToSelector:@selector(DTLivephotoViewDidLoad:videoTargetPath:imageTargetPath:)]) {
                [self.delegate DTLivephotoViewDidLoad:self videoTargetPath:videoFilePath imageTargetPath:imageFilePath];
            }
//            NSArray *urlArray = @[
//                                  [NSURL fileURLWithPath:videoFilePath],
//                                  [NSURL fileURLWithPath:imageFilePath]
//                                  ];
//            [PHLivePhoto requestLivePhotoWithResourceFileURLs:urlArray placeholderImage:weakSelf.placeholderImage targetSize:size contentMode:PHImageContentModeAspectFit resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
//                weakSelf.livePhotoView.livePhoto = livePhoto;
//                if (info[PHLivePhotoInfoCancelledKey] != nil) {
//                    weakSelf.livephoto = livePhoto;
//                    [weakSelf layoutLivephotoView];
//                    if (completion) {
//                        completion(livePhoto);
//                    }
//                }
//            }];
        }
    }];
}



#pragma -mark PHLivePhotoViewDelegate

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    
}


@end
