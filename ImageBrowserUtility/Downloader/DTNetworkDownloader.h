//
//  DTNetworkDownloader.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTDownloadRequest.h"

typedef void (^DTDownloadDataCompletion)(NSURL *fileURL, NSURL *videoURL, NSData *data, NSError *error);
typedef void (^DTDownloadProgressCallBack)(NSURL *videoURL, float progress);




@interface DTNetworkDownloader : NSObject

+ (instancetype)defaultDownloader;
@property (nonatomic) NSUInteger retryTimes;
@property (nonatomic) NSTimeInterval timeoutInterval;

- (void)dataWithURLString:(NSString *)URLString progress:(DTDownloadProgressCallBack)progressCallBack completion:(DTDownloadDataCompletion)completion;
- (void)dataWithURLString:(NSString *)URLString completion:(DTDownloadDataCompletion)completion;
+ (NSString *)cacheDirectory;
+ (NSString *)cacheFilePathForURL:(NSString *)URL;
+ (void)clearCache;

@end
