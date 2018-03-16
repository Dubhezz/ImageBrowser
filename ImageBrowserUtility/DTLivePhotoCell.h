//
//  DTLivePhotoCell.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/6/5.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PHLivePhotoView.h>
#import "DTImageBrowserCellProtocol.h"
#import "DTLivePhotoView.h"

@interface DTLivePhotoCell : UICollectionViewCell <DTImageBrowserCellProtocol>

@property (nonatomic, weak) id<DTImageBrowserCellProtocol> imageBrowserCellDelegate;

@property (nonatomic, strong) DTLivePhotoView *livePhotoView;
@property (nonatomic, strong, readonly) UIImage *image;

- (void)setLivePhotoWithImage:(UIImage *)image livePhotoVideoURL:(NSURL *)videoURL coverImageURL:(NSURL *)imageURL livePhotoVideoFilePath:(NSString *)videoFilePath coverImageFilePath:(NSString *)imagePath finishSend:(BOOL)isSend;

@end
