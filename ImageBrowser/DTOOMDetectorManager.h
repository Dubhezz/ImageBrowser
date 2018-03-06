//
//  DTOOMDetectorManager.h
//  ImageBrowser
//
//  Created by dubhe on 2018/3/6.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OOMDetector/libOOMDetector.h>

@interface DTOOMDetectorManager : NSObject <QQOOMPerformanceDataDelegate, QQOOMFileDataDelegate>

+ (instancetype)getInstance;

@property (nonatomic, copy) NSString *logString;

@end
