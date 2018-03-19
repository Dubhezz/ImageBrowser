//
//  DTLivePhotoView.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/16.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PHLivePhotoView.h>

typedef void (^DTLivephotoViewDidLoadImageCompletion)(PHLivePhoto *livephoto);

@class DTLivePhotoView;
@protocol DTLivephotoViewDelegate <NSObject>

- (void)DTLivephotoViewImageLoading:(DTLivePhotoView *)livephotoView targetVideoURL:(NSURL*)videoURL progress:(CGFloat)progress;
- (void)DTLivephotoViewDidLoad:(DTLivePhotoView *)livephotoView videoTargetPath:(NSString *)videoTargetPath imageTargetPath:(NSString *)imageTargetPath;

@end


@interface DTLivePhotoView : UIView

@property (nonatomic, weak) id<DTLivephotoViewDelegate> delegate;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@property (nonatomic, strong) UIImageView     *thumbnailImageView;
@property (nonatomic, strong) UIImage         *placeholderImage;

- (void)loadImageWithVideoURLString:(NSString *)videoURLString imageURLString:(NSString *)imageURLString targetSize:(CGSize)size completion:(DTLivephotoViewDidLoadImageCompletion)completion;

@end
