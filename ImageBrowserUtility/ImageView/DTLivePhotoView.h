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

@interface DTLivePhotoView : UIView

@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@property (nonatomic, strong) UIImageView     *thumbnailImageView;
@property (nonatomic, strong) UIImage         *placeholderImage;

- (void)loadImageWithVideoURLString:(NSString *)videoURLString imageURLString:(NSString *)imageURLString targetSize:(CGSize)size completion:(DTLivephotoViewDidLoadImageCompletion)completion;

@end
