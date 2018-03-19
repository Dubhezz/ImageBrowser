//
//  DTLivePhotoDownLoadManager.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DTNetworkDownloader.h"

typedef void(^DTLivePhotoOfOriginalImageCallBack)(UIImage * _Nullable image, NSError * _Nullable error);
typedef void(^DTLivePhotoOfVideoOriginalPathPathCallBack)(NSString * _Nullable originalVideoPath, NSError * _Nullable error);
typedef void(^DTLivePhotoDownloadCompletionBlock)(NSString * _Nullable imagefilePath, NSString * _Nullable videoFilePath, NSError * _Nullable error, NSURL * _Nullable imageURL, NSURL * _Nullable videoURL);
typedef void(^DTLivePhotoOfVideoTargetPathCallBack)(NSString * _Nullable videoFilePath, NSError * _Nullable error);
typedef void(^DTLivePhotoOfImageTargetPathCallBack)(NSString * _Nullable imageFilePath, NSError * _Nullable error);
typedef void(^DTLivePhotoSourcesCallBack)(NSString * _Nullable videoFilePath, NSString * _Nullable imageFilePath, NSError * _Nullable error);

@interface DTLivePhotoDownLoadManager : NSObject

- (void)downloadeVideoWithVideoURLString:(NSString *_Nullable)videoURLString imageURLString:(NSString *_Nullable)imageURLString mergeProgress:(DTDownloadProgressCallBack _Nullable )mergeProgress callBack:(DTLivePhotoSourcesCallBack _Nullable )callBack;
- (void)downloadeVideoWithVideoURLString:(NSString *_Nullable)videoURLString imageURLString:(NSString *_Nullable)imageURLString;
- (void)fetchVideoMetadataWithOriginalPath:(NSString *_Nullable)originalPath targetPath:(NSString *_Nullable)targetPath assetIdentifier:(NSString *_Nullable)assetIdentifier callBack:(DTLivePhotoOfVideoTargetPathCallBack _Nullable )callBack;
- (void)fetchImageMetadataWithOriginalImage:(UIImage *_Nullable)originalImage targetPath:(NSString *_Nullable)targetPath assetIdentifier:(NSString *_Nullable)assetIdentifier callBack:(DTLivePhotoOfImageTargetPathCallBack _Nullable )callBack;

@end
