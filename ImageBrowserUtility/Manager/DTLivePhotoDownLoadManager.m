//
//  DTLivePhotoDownLoadManager.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//


// error: Error Domain=NSCocoaErrorDomain Code=-1 "(null)" 可能是图片或者视频处理有问题
//
//

#import "DTLivePhotoDownLoadManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <PromiseKit/PromiseKit.h>

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


- (void)fetchLivePhotoSourceWithOriginalImage:(UIImage *)originalImage targetPath:(NSString *)targetPath originalVideoPath:(NSString *)originalVideoPath targetVideoPath:(NSString *)targetVideoPath assetIdentifier:(NSString *)assetIdentifier livePhotoSourcesCallBack:(DTLivePhotoSourcesCallBack)livePhotoSourcesCallBack {
//    __block NSError *fetchError = nil;
//    __block NSString *livePhotoVideoFilePath = nil;
//    __block NSString *livePhotoImageFilePath = nil;
    
//    dispatch_queue_t queue =   dispatch_queue_create("com.conCurrentQueue.queue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_async(group, queue, ^{
//        [self fetchImageMetadataWithOriginalImage:originalImage targetPath:targetPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable imageFilePath, NSError * _Nullable error) {
//            if (error) {
//                fetchError = error;
//            } else {
//                livePhotoImageFilePath = imageFilePath;
//            }
//        }];
//    });
//    dispatch_group_sync(group, queue, ^{
//        [self fetchVideoMetadataWithOriginalPath:originalVideoPath targetPath:targetVideoPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable videoFilePath, NSError * _Nullable error) {
//            if (error) {
//                fetchError = error;
//            } else {
//                livePhotoVideoFilePath = videoFilePath;
//            }
//        }];
//    });
//    dispatch_group_notify(group, queue, ^{
//        if (livePhotoSourcesCallBack) {
//            livePhotoSourcesCallBack(livePhotoVideoFilePath, livePhotoImageFilePath, fetchError);
//        }
//    });
    
//    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        [self fetchImageMetadataWithOriginalImage:originalImage targetPath:targetPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable imageFilePath, NSError * _Nullable error) {
//            if (error) {
//                fetchError = error;
//            } else {
//                livePhotoImageFilePath = imageFilePath;
//            }
//        }];
//    });
//    dispatch_sync(queue, ^{
//        [self fetchVideoMetadataWithOriginalPath:originalVideoPath targetPath:targetVideoPath assetIdentifier:assetIdentifier callBack:^(NSString * _Nullable videoFilePath, NSError * _Nullable error) {
//            if (error) {
//                fetchError = error;
//            } else {
//                livePhotoVideoFilePath = videoFilePath;
//            }
//        }];
//    });
//    dispatch_barrier_async(queue, ^{
//        if (livePhotoSourcesCallBack) {
//            livePhotoSourcesCallBack(livePhotoVideoFilePath, livePhotoImageFilePath, fetchError);
//        }
//    });
   
    PMKPromise *promise1 = [self promiseForFetchVideoMetadataWithOriginalPath:originalVideoPath targetPath:targetVideoPath assetIdentifier:assetIdentifier].then(^(NSString *videoFilePath) {
         return [PMKPromise promiseWithValue:videoFilePath];
    });
    PMKPromise *promise2 = [self promiseForFetchImageMetadataWithOriginalImage:originalImage targetPath:targetPath assetIdentifier:assetIdentifier].then(^(NSString *imageFilePath) {
        return [PMKPromise promiseWithValue:imageFilePath];
    });
    [PMKPromise when:@[promise1, promise2]].then(^(NSArray *sources){
        NSString *livePhotoVideoFilePath;
        NSString *livePhotoImageFilePath;
        for (NSString *path in sources) {
            if ([path hasSuffix:@".jpg"]) {
                livePhotoImageFilePath = path;
            } else if ([path hasSuffix:@".mov"]) {
                livePhotoVideoFilePath = path;
            } else {
                break;
            }
        }
        if (livePhotoSourcesCallBack) {
            livePhotoSourcesCallBack(livePhotoVideoFilePath,livePhotoImageFilePath, nil);
        }
    }).catch(^(NSError *error) {
        if (livePhotoSourcesCallBack) {
            livePhotoSourcesCallBack(nil,nil, error);
        }
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
    
    NSDictionary *audioDic = @{AVFormatIDKey :@(kAudioFormatLinearPCM),
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVLinearPCMBitDepthKey :@(16)
                               };
    
    AVAssetReaderTrackOutput *audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioDic];
    NSError *error;
    
    
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if([reader canAddOutput:videoOutput]) {
        [reader addOutput:videoOutput];
    } else {
        NSLog(@"Add video output errorn");
    }
    
    if([reader canAddOutput:audioOutput]) {
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
    
    AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[audioTrack mediaType] outputSettings:audioSettings];
    audioInput.expectsMediaDataInRealTime = true;
    audioInput.transform = audioTrack.preferredTransform;
    
    NSError *error_two;
    
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:targetPath] fileType:AVFileTypeQuickTimeMovie error:&error_two];
    if(error_two) {
        NSLog(@"CreateWriterError:%@n",error_two);
    }
    writer.metadata = @[ [self medatataForAssetIdentifier:assetIdentifier]];
    [writer addInput:videoInput];
    [writer addInput:audioInput];
    
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
                while (!videoInput.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData) {
                    usleep(1);
                }
                if (audioBuffer) {
                    BOOL isAppend = [audioInput appendSampleBuffer:audioBuffer];
                    CFRelease(audioBuffer);
                }

                BOOL isAppend = [adaptor.assetWriterInput appendSampleBuffer:videoBuffer];
                CMSampleBufferInvalidate(videoBuffer);
                CFRelease(videoBuffer);
                videoBuffer = nil;

            } else {
                continue;
            }
            // NULL?
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [writer finishWritingWithCompletionHandler:^{
                if (callBack) {
                    callBack(writer.outputURL.path,error_two);
                }
            }];
        });
    });
    
    
    while (writer.status == AVAssetWriterStatusWriting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }

//    AVAssetReaderOutput *videoOutput = nil;
//    AVAssetReaderOutput *audioOutput = nil;
//    AVAssetWriterInput *videoInput   = nil;
//    AVAssetWriterInput *audioInput   = nil;
//    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:originalPath]];
//    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
//    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
//    if (!videoTrack) {
//        return;
//    }
//    NSError *error;
//    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
//
//    videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
//
//    if ([reader canAddOutput:videoOutput]) {
//        [reader addOutput:videoOutput];
//    } else {
//        NSLog(@"add video output error ---- %@",error);
//    }
//
//    videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey: AVVideoCodecH264,
//                                                                                                     AVVideoWidthKey: [NSNumber numberWithFloat:videoTrack.naturalSize.width],
//                                                                                                     AVVideoHeightKey: [NSNumber numberWithFloat:videoTrack.naturalSize.height]
//                                                                                                     }];
//    videoInput.expectsMediaDataInRealTime = true;
//    videoInput.transform = videoTrack.preferredTransform;
//
//    if (asset.tracks.count > 1) {
//        audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:@{AVFormatIDKey :@(kAudioFormatLinearPCM),
//                                                                                                            AVLinearPCMIsBigEndianKey:@NO,
//                                                                                                            AVLinearPCMIsFloatKey:@NO,
//                                                                                                            AVLinearPCMBitDepthKey :@(16)
//                                                                                                            }];
//
//        if ([reader canAddOutput:audioOutput]) {
//            [reader addOutput:audioOutput];
//        } else {
//            NSLog(@"add audio output error ---- %@",error);
//        }
//
//        audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:@{AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatMPEG4AAC],
//                                                                                                         AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
//                                                                                                         AVSampleRateKey: [NSNumber numberWithFloat: 44100],
//                                                                                                         AVEncoderBitRateKey: [NSNumber numberWithInt: 128000]
//                                                                                                         }];
//        audioInput.expectsMediaDataInRealTime = true;
//        audioInput.transform = audioTrack.preferredTransform;
//    }
//
//
//
//    NSError *writer_error;
//    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:targetPath] fileType:AVFileTypeQuickTimeMovie error:&writer_error];
//    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey :[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
//    AVAssetWriterInputMetadataAdaptor *metadataAdaptor = [self metadataAdapter];
//    writer.metadata = @[[self medatataForAssetIdentifier:assetIdentifier]];
//    [writer addInput:metadataAdaptor.assetWriterInput];
//    [writer startWriting];
//    [reader startReading];
//    [writer startSessionAtSourceTime:kCMTimeZero];
//
//    [metadataAdaptor appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc] initWithItems:@[[self metadataForStillImage]] timeRange:CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000))]];
//
//    dispatch_queue_t videoWriterQueue = dispatch_queue_create("VideoWriterQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(videoWriterQueue, ^{
//        while (reader.status == AVAssetReaderStatusReading) {
//            CMSampleBufferRef videoBuffer = [videoOutput copyNextSampleBuffer];
//            CMSampleBufferRef audioBuffer = [audioOutput copyNextSampleBuffer];
//            if (videoBuffer) {
//                while (!videoInput.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData) {
//                    usleep(1);
//                }
//                if (audioBuffer) {
//                    [audioInput appendSampleBuffer:audioBuffer];
//                    CFRelease(audioBuffer);
//                }
//                [pixelBufferAdaptor.assetWriterInput appendSampleBuffer:videoBuffer];
//                CMSampleBufferInvalidate(videoBuffer);
//                CFRelease(videoBuffer);
//                videoBuffer = nil;
//            } else {
//                continue;
//            }
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [writer finishWritingWithCompletionHandler:^{
//                    NSLog(@"Finish \n");
//                    if (callBack) {
//                        callBack(writer.outputURL.path,writer_error);
//                    }
//                }];
//            });
//        }
//    });
//
//    while (writer.status == AVAssetWriterStatusWriting) {
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
//    }
}

- (AVAssetWriterInputMetadataAdaptor *)metadataAdapter {
//    NSString *identifier = [kKeySpaceQuickTimeMetadata stringByAppendingFormat:@"/%@",kKeyStillImageTime];
//    NSDictionary *spec = @{(id)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier :
//                               identifier,
//                           (id)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType:
//                               @"com.apple.metadata.datatype.int8"};
//    CMFormatDescriptionRef desc;
//    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef _Nonnull)(@[spec]), &desc);
//    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
//    CFRelease(desc);
//    return [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
    
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
    item.dataType = @"com.apple.metadata.datatype.int8";
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



