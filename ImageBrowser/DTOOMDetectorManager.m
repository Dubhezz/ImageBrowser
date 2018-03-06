//
//  DTOOMDetectorManager.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/6.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTOOMDetectorManager.h"

@implementation DTOOMDetectorManager

+ (instancetype)getInstance
{
    static DTOOMDetectorManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DTOOMDetectorManager new];
    });
    return manager;
}


- (void)performanceData:(NSDictionary *)data completionHandler:(void (^)(BOOL))completionHandler
{
    //    NSLog(@"%@ \n", data);
    
    completionHandler(YES);
}

- (void)fileData:(NSData *)data extra:(NSDictionary<NSString *,NSString *> *)extra type:(QQStackReportType)type completionHandler:(void (^)(BOOL))completionHandler
{
//        NSLog(@"\n %@ \n %ld \n %@\n", extra, type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    if (type == QQStackReportTypeOOMLog) {
        // 此处为了Demo演示需要传参数NO，NO表示我们自己业务对data处理尚未完成或者失败，OOMDetector内部暂时不会删除临时文件
        completionHandler(NO);
    } else {
        completionHandler(YES);
    }
}

@end
