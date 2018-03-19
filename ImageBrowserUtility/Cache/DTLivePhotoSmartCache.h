//
//  DTLivePhotoSmartCache.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/19.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTLivePhotoCacheManager.h"
#import <PhotosUI/PHLivePhotoView.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTLivePhotoSmartCache : DTLivePhotoCache

+ (instancetype)defaultCache;
- (NSString *)cacheKeyForVideoURLString:(NSString *)videoURLString;
- (void)addLivePhotoSource:(NSArray *)livePhotoSources forKey:(NSString *)key;
- (NSArray *)livePhotoPathForKey:(NSString *)key;
- (void)celar;

@end

NS_ASSUME_NONNULL_END
