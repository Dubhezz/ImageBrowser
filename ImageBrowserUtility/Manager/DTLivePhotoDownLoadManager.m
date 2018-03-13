//
//  DTLivePhotoDownLoadManager.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTLivePhotoDownLoadManager.h"

@implementation DTLivePhotoDownLoadManager

+ (nullable instancetype)shareManager {
    return [self new];
}
- (nonnull instancetype)init {
//    SDImageCache *cache = [SDImageCache sharedImageCache];
//    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    return [self initWithCache:nil downloader:nil];
}

- (nonnull instancetype)initWithCache:(id)cache downloader:(id)downloader {
    if (self = [super init]) {
        
    }
    return self;
}

@end
