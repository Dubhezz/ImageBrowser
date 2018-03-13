//
//  DTLivePhotoDownLoadManager.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DTLivePhotoDownloadCompletionBlock)(NSString * _Nullable imagefilePath, NSString * _Nullable videoFilePath, NSError * _Nullable error, NSURL * _Nullable imageURL, NSURL * _Nullable videoURL);

@interface DTLivePhotoDownLoadManager : NSObject

+ (nullable instancetype)shareManager;
- (void)downCoverImageWithImageURL:(nullable NSURL *)imageURL videoURL:(nullable NSURL *)videoURL completion:(nullable DTLivePhotoDownloadCompletionBlock)completion;

@end
