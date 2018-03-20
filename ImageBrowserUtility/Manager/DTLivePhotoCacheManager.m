//
//  DTLivePhotoCacheManager.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/19.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTLivePhotoCacheManager.h"

@implementation DTLivePhotoCache

- (NSArray *)livePhotoSourcePathForKey:(NSString *)key {
    return nil;
}

- (void)cacheLivePhotoSourcePath:(NSArray *)array forKey:(NSString *)key {
    
}

- (void)clearCache {
    
}

@end

@implementation DTLivePhotoCacheManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static DTLivePhotoCacheManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)clearDiskCache {
    [[NSFileManager defaultManager] removeItemAtPath:self.cachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:self.originalVideoPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.originalVideoPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (NSString *)cachePath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
                      stringByAppendingPathComponent:@"movs/"];
    return path;
}

- (NSString *)originalVideoPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
                      stringByAppendingPathComponent:@"videos/"];
    return path;
}

@end
