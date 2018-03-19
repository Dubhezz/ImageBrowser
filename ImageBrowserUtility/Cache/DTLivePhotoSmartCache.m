//
//  DTLivePhotoSmartCache.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/19.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTLivePhotoSmartCache.h"
#import <objc/runtime.h>

@interface DTLivePhotoSmartCache ()

@property (nonatomic, strong) NSMapTable<NSString *, NSArray *> *table;

@end

@implementation DTLivePhotoSmartCache

+ (instancetype)defaultCache {
    NSAssert([NSThread isMainThread], @"must run in mainthread");
    static DTLivePhotoSmartCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DTLivePhotoSmartCache alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init])
    {
        self.table = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    }
    return self;
}

- (NSString *)cacheKeyForVideoURLString:(NSString *)videoURLString {
    if (videoURLString.length > 0) {
        return videoURLString;
    } else {
        return @"";
    }
}

- (void)addLivePhotoSource:(NSArray *)livePhotoSources forKey:(NSString *)key {
    [self.table setObject:livePhotoSources forKey:key];
}

- (NSArray *)livePhotoPathForKey:(NSString *)key {
    return [self.table objectForKey:key];
}

- (void)celar {
    [self.table removeAllObjects];
}

@end
