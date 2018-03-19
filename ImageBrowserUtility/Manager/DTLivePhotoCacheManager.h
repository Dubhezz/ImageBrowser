//
//  DTLivePhotoCacheManager.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/19.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PhotosDefines.h>

@interface DTLivePhotoCache :NSObject

- (NSArray *)livePhotoSourcePathForKey:(NSString *)key;
- (void)cacheLivePhotoSourcePath:(NSArray *)array forKey:(NSString *)key;
- (void)clearCache;


@end

@interface DTLivePhotoCacheManager : NSObject

@end
