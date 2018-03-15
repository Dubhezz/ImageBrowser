//
//  DTLivePhotoDownLoadManager.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DTLivePhotoDownloadCompletionBlock)(NSString * _Nullable imagefilePath, NSString * _Nullable videoFilePath, NSError * _Nullable error, NSURL * _Nullable imageURL, NSURL * _Nullable videoURL);

typedef void(^DTLivePhotoOfVideoTargetPathCallBack)(NSString * _Nullable videoFilePath, NSError * _Nullable error);
typedef void(^DTLivePhotoOfImageTargetPathCallBack)(NSString * _Nullable imageFilePath, NSError * _Nullable error);
typedef void(^DTLivePhotoSourcesCallBack)(NSString * _Nullable videoFilePath, NSString * _Nullable imageFilePath, NSError * _Nullable error);

@interface DTLivePhotoDownLoadManager : NSObject

- (void)fetchLivePhotoSourceWithOriginalImage:(UIImage *_Nullable)originalImage targetPath:(NSString *_Nullable)targetPath originalVideoPath:(NSString *_Nullable)originalVideoPath targetVideoPath:(NSString *_Nullable)targetVideoPath assetIdentifier:(NSString *_Nullable)assetIdentifier livePhotoSourcesCallBack:(DTLivePhotoSourcesCallBack _Nullable )livePhotoSourcesCallBack;
- (void)fetchVideoMetadataWithOriginalPath:(NSString *_Nullable)originalPath targetPath:(NSString *_Nullable)targetPath assetIdentifier:(NSString *_Nullable)assetIdentifier callBack:(DTLivePhotoOfVideoTargetPathCallBack _Nullable )callBack;
- (void)fetchImageMetadataWithOriginalImage:(UIImage *_Nullable)originalImage targetPath:(NSString *_Nullable)targetPath assetIdentifier:(NSString *_Nullable)assetIdentifier callBack:(DTLivePhotoOfImageTargetPathCallBack _Nullable )callBack;

@end
