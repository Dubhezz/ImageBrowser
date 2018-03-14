//
//  DTNetworkDownloader.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTNetworkDownloader.h"
#import "NSString+MD5.h"

@interface DTNetworkDownloaderTask : NSObject

@property (nonatomic, strong) NSURLSessionTask          *task;
@property (nonatomic, strong) NSURLRequest             *request;
@property (nonatomic, copy)   DTDownloadDataCompletion  completion;
@property (nonatomic, strong) NSMutableData             *data;
@property (nonatomic, assign) NSUInteger                totalLength;
@property (nonatomic, assign) NSUInteger                retryTimes;

@end

@implementation DTNetworkDownloaderTask

@end

@interface DTNetworkDownloader () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSOperationQueue *sessionQueue;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMapTable *reqTable;
@property (nonatomic, strong) NSMapTable *taskTable;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;
@property (nonatomic, strong) dispatch_queue_t gcd_queue;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation DTNetworkDownloader

- (instancetype)init
{
    if (self = [super init])
    {
        _lock = [[NSLock alloc] init];
        _gcd_queue                         = dispatch_queue_create(nil, nil);
        _queue                             = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
        _semaphore                         = dispatch_semaphore_create(0);
        [self setup];
    }
    return self;
}

- (void)setup {
    self.reqTable                                 = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    self.taskTable                                = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    self.sessionQueue                             = [[NSOperationQueue alloc] init];
    self.sessionQueue.name                        = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
    self.sessionQueue.maxConcurrentOperationCount = 20;
    self.session                                  = [NSURLSession
                                                     sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                     delegateQueue:self.sessionQueue];
    self.timeoutInterval                          = 30;
    self.retryTimes                               = 3;
    self.queue.maxConcurrentOperationCount = 20;
}

- (void)dataWithURLString:(NSString *)URLString completion:(DTDownloadDataCompletion)completion {
    if (!([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"])) {
        NSError *error = [NSError errorWithDomain:@"DTDownloaderError" code:-3 userInfo:@{NSLocalizedDescriptionKey:@"InvalidRequest"}];
        completion(URLString, nil, 0, error);
        return;
    }
#warning 缓存中查询是否下载逻辑
    //缓存中查询
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URLString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.timeoutInterval];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request];
    DTNetworkDownloaderTask *downloaderTask = [[DTNetworkDownloaderTask alloc] init];
    downloaderTask.task = task;
    downloaderTask.request = request;
    downloaderTask.completion = completion;
    downloaderTask.data = [NSMutableData data];
    [self.lock lock];
//    [self.reqTable setObject:downloaderTask forKey:request.keyForLoader];
    [self.taskTable setObject:downloaderTask forKey:@(task.taskIdentifier)];
    [self.lock unlock];
    
    [task resume];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    self.reqTable = nil;
    self.taskTable = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *rsp = (NSHTTPURLResponse *) response;
        NSString *num          = rsp.allHeaderFields[@"Content-Length"];
        if ([num isKindOfClass:[NSString class]])
        {
            [self.lock lock];
            DTNetworkDownloaderTask *downloaderTask = [self.taskTable objectForKey:@(dataTask.taskIdentifier)];
            [self.lock unlock];
            downloaderTask.totalLength                   = [num integerValue];
        }
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.lock lock];
    DTNetworkDownloaderTask *downloaderTask = [self.taskTable objectForKey:@(dataTask.taskIdentifier)];
    [self.lock unlock];
    DTDownloadDataCompletion completion      = downloaderTask.completion;
    NSMutableData *recvdata                  = downloaderTask.data;
    NSURLRequest *request                    = downloaderTask.request;
    [recvdata appendData:data];
    if (completion)
    {
        float progress = recvdata.length / (float) downloaderTask.totalLength;
        if (progress > 1)
        {
            progress = 1;
        }
        if (isinf(progress))
        {
            progress = 0;
        }
        if (progress < 1)
        {
            completion(request.URL, recvdata, progress, nil);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self.lock lock];
    DTNetworkDownloaderTask *downloaderTask = [self.taskTable objectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
    if (!downloaderTask)
    {
        return;
    }
    
    DTDownloadDataCompletion completion = downloaderTask.completion;
    NSMutableData *data          = downloaderTask.data;
    NSURLRequest *request        = downloaderTask.request;
    [self.lock lock];
//    [self.reqTable removeObjectForKey:request.keyForLoader];
    [self.taskTable removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
    NSURL *fileURL = [NSURL fileURLWithPath:[DTNetworkDownloader cacheFilePathForURL:request.URL.absoluteString]];
    if (error)
    {
        if (error.code != NSURLErrorCancelled)
        {
            if (downloaderTask.retryTimes < self.retryTimes)
            {
                downloaderTask.retryTimes++;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.gcd_queue, ^{
                    [self dataWithURLString:request.URL.absoluteString completion:completion];
                });
            }
            else
            {
                if (completion)
                {
                    completion(request.URL, nil, 1, error);
                }
            }
            
        }
        else
        {
            if (completion)
            {
                completion(request.URL, nil, 1, error);
            }
        }
    }
    else
    {
        [data writeToURL:fileURL atomically:YES];
        if (completion)
        {
            completion(fileURL, data, 1, error);
        }
    }
}

+ (NSString *)cacheDirectory
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
                      stringByAppendingPathComponent:@"videos/"];
    
    return path;
}

+ (NSString *)cacheFilePathForURL:(NSString *)URL
{
    NSString *path = [self cacheDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:true
                                               attributes:nil
                                                    error:nil];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NSString MD5:URL]]];
}

+ (void)clearCache
{
    [NSFileManager.defaultManager removeItemAtPath:[self cacheDirectory] error:nil];
}


- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    self.reqTable = nil;
    self.taskTable = nil;
}

@end
