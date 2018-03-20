//
//  DTLivePhotoDownLoadManager.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//


// error: Error Domain=NSCocoaErrorDomain Code=-1 "(null)" 可能是图片或者视频处理有问题 (注意AVMutableMetadataItem dataType的设置 )
//
//

#import "DTLivePhotoDownLoadManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <PromiseKit/PromiseKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DTNetworkDownloader.h"
#import "DTUtil.h"
#import "DTLivePhotoSmartCache.h"
#import "DTLivePhotoCacheManager.h"

NSString *const kKeyContentIdentifier =  @"com.apple.quicktime.content.identifier";
NSString *const kKeySpaceQuickTimeMetadata = @"mdta";
NSString *const kKeyStillImageTime = @"com.apple.quicktime.still-image-time";
NSString *const kFigAppleMakerNote_AssetIdentifier = @"17";

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

- (void)downloadeVideoWithVideoURLString:(NSString *)videoURLString imageURLString:(NSString *)imageURLString mergeProgress:(DTDownloadProgressCallBack)mergeProgress callBack:(DTLivePhotoSourcesCallBack)callBack {
   
    if (videoURLString.length == 0 || imageURLString.length == 0) {
        return;
    }
    
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
//                      stringByAppendingPathComponent:@"movs/"];
    NSString *path = [[DTLivePhotoCacheManager shareManager] cachePath];
    NSString *videoTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[DTUtil MD5:videoURLString]]];
    NSString *imageTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[DTUtil MD5:videoURLString]]];
    NSString *identifier = [[NSUUID UUID] UUIDString];
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (folderExists) {
//        videoTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[DTUtil MD5:videoURLString]]];
//        imageTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[DTUtil MD5:videoURLString]]];
        BOOL videoPathExists = [[NSFileManager defaultManager] fileExistsAtPath:videoTargetPath];
        BOOL imagePathExists = [[NSFileManager defaultManager] fileExistsAtPath:imageTargetPath];
        if (videoPathExists && imagePathExists) {
            if (callBack) {
                callBack(videoTargetPath, imageTargetPath, nil);
                return;
            }
        }
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:true
                                                   attributes:nil
                                                        error:nil];
//        videoTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[DTUtil MD5:videoURLString]]];
//        imageTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[DTUtil MD5:videoURLString]]];
    }
    
    
        
//    if (videoURLString.length == 0 || imageURLString == 0) {
//        return;
//    }
//    PMKPromise *promise1 = [self promiseForDownloadImageWithURLString:imageURLString].then(^(UIImage *image){
//        return [PMKPromise promiseWithValue:image];
//    });
//    PMKPromise *promise2 = [self promiseForDownloadVideoWithString:videoURLString progressCallBack:mergeProgress].then(^(NSString *videoOriginalPath) {
//        return [PMKPromise promiseWithValue:videoOriginalPath];
//    });
//    [PMKPromise when:@[promise1, promise2]].then(^(NSArray *sources) {
//        UIImage *image;
//        NSString *videoOriginalPath;
//        for (id obj in sources) {
//            if ([obj isKindOfClass:[UIImage class]]) {
//                image = (UIImage *)obj;
//            } else if ([obj isKindOfClass:[NSString class]] && [obj hasSuffix:@".mp4"]) {
//                videoOriginalPath = (NSString *)obj;
//            } else {
//                break;
//            }
//        }
//        [self fetchLivePhotoSourceWithOriginalImage:image targetPath:imageTargetPath originalVideoPath:videoOriginalPath targetVideoPath:videoTargetPath assetIdentifier:identifier livePhotoSourcesCallBack:callBack];
//    }).catch(^(NSError *error) {
//        if (callBack) {
//            callBack(nil, nil, error);
//        }
//    });
    __block UIImage *originalImage = nil;
    __block NSString *videoOriginalPath = nil;
    __block NSError *downloadError = nil;
    dispatch_queue_t queue = dispatch_queue_create("111", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self downloadImageWithURLString:imageURLString originalImageCallBack:^(UIImage * _Nullable image, NSError * _Nullable error) {
            if (error) {
                downloadError = error;
            } else {
                originalImage = image;
            }
            NSLog(@"任务---- 1 ---- %@", [NSThread currentThread]);
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self downloadeVideoWithVideoURLString:videoURLString progressCallBack:mergeProgress videoOriginalPathCallBack:^(NSString * _Nullable originalVideoPath, NSError * _Nullable error) {
            if (error) {
                downloadError = error;
            } else {
                videoOriginalPath = originalVideoPath;
            }
            NSLog(@"任务---- 2 ---- %@", [NSThread currentThread]);
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, queue, ^{
        [self fetchLivePhotoSourceWithOriginalImage:originalImage targetPath:imageTargetPath videoURLString:videoURLString originalVideoPath:videoOriginalPath targetVideoPath:videoTargetPath assetIdentifier:identifier livePhotoSourcesCallBack:callBack];
    });
    
    
}

- (PMKPromise *)promiseForDownloadImageWithURLString:(NSString *)imageURLString {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        [self downloadImageWithURLString:imageURLString originalImageCallBack:^(UIImage * _Nullable image, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(image);
            }
        }];
    }];
}

- (PMKPromise *)promiseForDownloadVideoWithString:(NSString *)string progressCallBack:(DTDownloadProgressCallBack)progressCallBack {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        [self downloadeVideoWithVideoURLString:string progressCallBack:progressCallBack videoOriginalPathCallBack:^(NSString * _Nullable originalVideoPath, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(originalVideoPath);
            }
        }];
    }];
}

- (void)downloadImageWithURLString:(NSString *)URLString originalImageCallBack:(DTLivePhotoOfOriginalImageCallBack)imageCallBack {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    SDWebImageOptions options = SDWebImageQueryDataWhenInMemory;
    [manager loadImageWithURL:[NSURL URLWithString:URLString] options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([weakSlef.delegate respondsToSelector:@selector(DTImageViewImageLoading:targetImageURL:progress:)] && [imageURL.absoluteString isEqualToString:targetURL.absoluteString]) {
//                [weakSlef.delegate DTImageViewImageLoading:weakSlef targetImageURL:targetURL progress:receivedSize/(CGFloat)expectedSize];
//            }
//        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!error && image) {
            if (imageCallBack) {
                imageCallBack(image, error);
            }
        } else {
            if (imageCallBack) {
                imageCallBack(nil, error);
            }
        }
    }];
}

- (void)downloadeVideoWithVideoURLString:(NSString *)videoURLString  progressCallBack:(DTDownloadProgressCallBack)progressCallBack videoOriginalPathCallBack:(DTLivePhotoOfVideoOriginalPathPathCallBack)videoPathCallBack {
    [[DTNetworkDownloader defaultDownloader] dataWithURLString:videoURLString progress:progressCallBack completion:^(NSURL *fileURL, NSURL *videoURL, NSData *data, NSError *error) {
        if (!error && fileURL) {
            if (videoPathCallBack) {
                videoPathCallBack(fileURL.path, error);
            } else {
                videoPathCallBack(nil, error);
            }
        }
    }];
}


- (void)fetchLivePhotoSourceWithOriginalImage:(UIImage *)originalImage targetPath:(NSString *)imageTargetPath videoURLString:(NSString *)videoURLString originalVideoPath:(NSString *)originalVideoPath targetVideoPath:(NSString *)targetVideoPath assetIdentifier:(NSString *)assetIdentifier livePhotoSourcesCallBack:(DTLivePhotoSourcesCallBack)livePhotoSourcesCallBack {
//    PMKPromise *promise1 = [self promiseForFetchVideoMetadataWithOriginalPath:originalVideoPath targetPath:targetVideoPath assetIdentifier:assetIdentifier].then(^(NSString *videoFilePath) {
//         return [PMKPromise promiseWithValue:videoFilePath];
//    });
//    PMKPromise *promise2 = [self promiseForFetchImageMetadataWithOriginalImage:originalImage targetPath:targetPath assetIdentifier:assetIdentifier].then(^(NSString *imageFilePath) {
//        return [PMKPromise promiseWithValue:imageFilePath];
//    });
//    [PMKPromise when:@[promise1, promise2]].then(^(NSArray *sources){
//        NSString *livePhotoVideoFilePath;
//        NSString *livePhotoImageFilePath;
//        for (NSString *path in sources) {
//            if ([path hasSuffix:@".jpg"]) {
//                livePhotoImageFilePath = path;
//            } else if ([path hasSuffix:@".mov"]) {
//                livePhotoVideoFilePath = path;
//            } else {
//                break;
//            }
//        }
//        if (livePhotoSourcesCallBack) {
//            livePhotoSourcesCallBack(livePhotoVideoFilePath,livePhotoImageFilePath, nil);
//        }
//    }).catch(^(NSError *error) {
//        if (livePhotoSourcesCallBack) {
//            livePhotoSourcesCallBack(nil,nil, error);
//        }
//    });
   
    __block NSString *imagePath = nil;
    __block NSString *videoPath = nil;
    __block NSError *writerError = nil;
    dispatch_queue_t queue = dispatch_queue_create("222", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self fetchImageMetadataWithOriginalImage:originalImage targetPath:imageTargetPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable imageFilePath, NSError * _Nullable error) {
            if (error) {
                imagePath = nil;
                writerError = error;
            } else {
                imagePath = imageFilePath;
            }
            NSLog(@"任务---- 4 ---- %@", [NSThread currentThread]);
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self fetchVideoMetadataWithOriginalPath:originalVideoPath targetPath:targetVideoPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable videoFilePath, NSError * _Nullable error) {
            if (error) {
                videoPath = nil;
                writerError = error;
            } else {
                videoPath = videoFilePath;
            }
            NSLog(@"任务---- 5 ---- %@", [NSThread currentThread]);
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (writerError) {
                if (livePhotoSourcesCallBack) {
                    livePhotoSourcesCallBack(nil,nil, writerError);
                }
            } else {
                if (livePhotoSourcesCallBack) {
//                    DTLivePhotoSmartCache *cache = [DTLivePhotoSmartCache defaultCache];
//                    NSString *key = [[DTLivePhotoSmartCache defaultCache] cacheKeyForVideoURLString:videoURLString];
//                    [cache addLivePhotoSource:@[videoPath,imagePath] forKey:key];
                    livePhotoSourcesCallBack(videoPath,imagePath, nil);
                    //删除原视频
                     [[NSFileManager defaultManager] removeItemAtPath:originalVideoPath error:nil];
                }
            }
            NSLog(@"任务---- 6 ---- %@", [NSThread currentThread]);
        });
    });
    
    
}

- (PMKPromise *)promiseForFetchVideoMetadataWithOriginalPath:(NSString *)originalPath targetPath:(NSString *)targetPath assetIdentifier:(NSString *)assetIdentifier {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        [self fetchVideoMetadataWithOriginalPath:originalPath targetPath:targetPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable videoFilePath, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(videoFilePath);
            }
        }];
    }];
}

- (PMKPromise *)promiseForFetchImageMetadataWithOriginalImage:(UIImage *)originalImage targetPath:(NSString *)targetPath assetIdentifier:(NSString *)assetIdentifier {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        [self fetchImageMetadataWithOriginalImage:originalImage targetPath:targetPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable imageFilePath, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(imageFilePath);
            }
        }];
    }];
}


//视频处理
- (void)fetchVideoMetadataWithOriginalPath:(NSString *)originalPath targetPath:(NSString *)targetPath assetIdentifier:(NSString *)assetIdentifier callBack:(DTLivePhotoOfVideoTargetPathCallBack _Nullable )callBack {
    AVURLAsset* asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:originalPath]];
    
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    if (!videoTrack) {
        return;
    }
    
    AVAssetReaderOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    
    
    AVAssetReaderTrackOutput *audioOutput = nil;
    
    NSDictionary *audioDic = @{AVFormatIDKey :@(kAudioFormatLinearPCM),
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVLinearPCMBitDepthKey :@(16)
                               };
    if (audioTrack) {
        audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioDic];
    }
    
    NSError *error;
    
    
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if([reader canAddOutput:videoOutput]) {
        [reader addOutput:videoOutput];
    } else {
        NSLog(@"Add video output errorn");
    }
    
    if(audioOutput && [reader canAddOutput:audioOutput]) {
        [reader addOutput:audioOutput];
    } else {
        NSLog(@"Add audio output errorn");
    }
    
    
    NSDictionary * outputSetting = @{AVVideoCodecKey: AVVideoCodecH264,
                                     AVVideoWidthKey: [NSNumber numberWithFloat:videoTrack.naturalSize.width],
                                     AVVideoHeightKey: [NSNumber numberWithFloat:videoTrack.naturalSize.height]
                                     };
    
    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSetting];
    videoInput.expectsMediaDataInRealTime = true;
    videoInput.transform = videoTrack.preferredTransform;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [ NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   [ NSNumber numberWithFloat: 44100], AVSampleRateKey,
                                   [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                                   nil];
    AVAssetWriterInput *audioInput = nil;
    if (audioTrack) {
        audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[audioTrack mediaType] outputSettings:audioSettings];
        audioInput.expectsMediaDataInRealTime = true;
        audioInput.transform = audioTrack.preferredTransform;
    }
    
    
    NSError *error_two;
    
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:targetPath] fileType:AVFileTypeQuickTimeMovie error:&error_two];
    if(error_two) {
        NSLog(@"CreateWriterError:%@n",error_two);
    }
    writer.metadata = @[ [self medatataForAssetIdentifier:assetIdentifier]];
    [writer addInput:videoInput];
    if (audioInput) [writer addInput:audioInput];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                                           kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    AVAssetWriterInputMetadataAdaptor *adapter = [self metadataAdapter];
    [writer addInput:adapter.assetWriterInput];
    [writer startWriting];
    [reader startReading];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    
    CMTimeRange dummyTimeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000));
    //Meta data reset:
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyStillImageTime;
    item.keySpace = kKeySpaceQuickTimeMetadata;
    item.value = [NSNumber numberWithInt:0];
    item.dataType = @"com.apple.metadata.datatype.int8";
    [adapter appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc] initWithItems:[NSArray arrayWithObject:item] timeRange:dummyTimeRange]];
    

    dispatch_queue_t createMovQueue = dispatch_queue_create("createMovQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(createMovQueue, ^{
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef videoBuffer = [videoOutput copyNextSampleBuffer];
            CMSampleBufferRef audioBuffer = [audioOutput copyNextSampleBuffer];
            if (videoBuffer) {
                while (audioInput ? (!videoInput.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData) : !videoInput.isReadyForMoreMediaData) {
                    usleep(1/ 30.0);
                }
                if (audioBuffer) {
                    if (audioInput.isReadyForMoreMediaData) {
                        BOOL isAppend = [audioInput appendSampleBuffer:audioBuffer];
                    }
                    CFRelease(audioBuffer);
                }
                if (videoInput.isReadyForMoreMediaData) {
                    BOOL isAppend = [adaptor.assetWriterInput appendSampleBuffer:videoBuffer];
                }
                CMSampleBufferInvalidate(videoBuffer);
                CFRelease(videoBuffer);
                videoBuffer = nil;

            } else {
                continue;
            }
            // NULL?
        }
//        dispatch_sync(dispatch_get_main_queue(), ^{
            [writer finishWritingWithCompletionHandler:^{
                if (callBack) {
                    callBack(writer.outputURL.path,error_two);
                }
            }];
//        });
    });
    
    
    while (writer.status == AVAssetWriterStatusWriting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (AVAssetWriterInputMetadataAdaptor *)metadataAdapter {
    NSString *identifier = [kKeySpaceQuickTimeMetadata stringByAppendingFormat:@"/%@",kKeyStillImageTime];
    const NSDictionary *spec = @{(__bridge_transfer NSString*)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier :
                                     identifier,
                                 (__bridge_transfer NSString*)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType :
                                     @"com.apple.metadata.datatype.int8"
                                 };
    CMFormatDescriptionRef desc;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)@[spec], &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    CFRelease(desc);
    return [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
    
}

- (AVMetadataItem *)medatataForAssetIdentifier:(NSString *)assetIdentifier {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyContentIdentifier;
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.value = assetIdentifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    return item;
}

- (AVMetadataItem *)metadataForStillImage {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyStillImageTime;
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.value = [[NSNumber alloc] initWithInt:0];
    item.dataType = @"com.apple.metadata.datatype.int8";
    return item;
}

//图片处理
- (void)fetchImageMetadataWithOriginalImage:(UIImage *)originalImage targetPath:(NSString *)targetPath assetIdentifier:(NSString *)assetIdentifier callBack:(DTLivePhotoOfImageTargetPathCallBack _Nullable )callBack {
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:targetPath], kUTTypeJPEG, 1, nil);
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)UIImageJPEGRepresentation(originalImage, 1), nil);
    NSMutableDictionary *metaData = [(__bridge_transfer  NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) mutableCopy];
    
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setValue:assetIdentifier forKey:kFigAppleMakerNote_AssetIdentifier];
    [metaData setValue:makerNote forKey:(__bridge_transfer  NSString*)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(dest, imageSourceRef, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    if (callBack) {
        callBack(targetPath,nil);
    }
    
}

@end



