//
//  DTLivePhotoDownLoadManager.m
//  ImageBrowser
//
//  Created by dubhe on 2018/3/13.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "DTLivePhotoDownLoadManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

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

//视频处理
- (void)fetchVideoMetadataWithOriginalPath:(NSURL *)originalPath targetPath:(NSString *)targetPath assetIdentifier:(NSString *)assetIdentifier {
    AVAssetReaderOutput *videoOutput = nil;
    AVAssetReaderOutput *audioOutput = nil;
    AVAssetWriterInput *videoInput   = nil;
    AVAssetWriterInput *audioInput   = nil;
    AVURLAsset *asset = [AVURLAsset assetWithURL:originalPath];
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (!videoTrack) {
        return;
    }
    NSError *error;
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    
    videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    
    if ([reader canAddOutput:videoOutput]) {
        [reader addOutput:videoOutput];
    } else {
        NSLog(@"add video output error ---- %@",error);
    }
    
    videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey: AVVideoCodecH264,
                                                                                                     AVVideoWidthKey: [NSNumber numberWithFloat:videoTrack.naturalSize.width],
                                                                                                     AVVideoHeightKey: [NSNumber numberWithFloat:videoTrack.naturalSize.height]
                                                                                                     }];
    videoInput.expectsMediaDataInRealTime = true;
    videoInput.transform = videoTrack.preferredTransform;
    
    if (asset.tracks.count > 1) {
        audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:@{AVFormatIDKey :@(kAudioFormatLinearPCM),
                                                                                                            AVLinearPCMIsBigEndianKey:@NO,
                                                                                                            AVLinearPCMIsFloatKey:@NO,
                                                                                                            AVLinearPCMBitDepthKey :@(16)
                                                                                                            }];
        
        if ([reader canAddOutput:audioOutput]) {
            [reader addOutput:audioOutput];
        } else {
            NSLog(@"add audio output error ---- %@",error);
        }
        
        audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:@{AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatMPEG4AAC],
                                                                                                         AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
                                                                                                         AVSampleRateKey: [NSNumber numberWithFloat: 44100],
                                                                                                         AVEncoderBitRateKey: [NSNumber numberWithInt: 128000]
                                                                                                         }];
        audioInput.expectsMediaDataInRealTime = true;
        audioInput.transform = audioTrack.preferredTransform;
    }
    
    
    
    NSError *writer_error;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:targetPath] fileType:AVFileTypeQuickTimeMovie error:&writer_error];
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey :[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    AVAssetWriterInputMetadataAdaptor *metadataAdaptor = [self metadataAdapter];
    writer.metadata = @[[self medatataForAssetIdentifier:assetIdentifier]];
    [writer addInput:metadataAdaptor.assetWriterInput];
    [writer startWriting];
    [reader startReading];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    [metadataAdaptor appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc] initWithItems:@[[self metadataForStillImage]] timeRange:CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000))]];
    
    dispatch_queue_t videoWriterQueue = dispatch_queue_create("VideoWriterQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(videoWriterQueue, ^{
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef videoBuffer = [videoOutput copyNextSampleBuffer];
            CMSampleBufferRef audioBuffer = [audioOutput copyNextSampleBuffer];
            if (videoBuffer) {
                while (!videoInput.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData) {
                    usleep(1);
                }
                if (audioBuffer) {
                    [audioInput appendSampleBuffer:audioBuffer];
                    CFRelease(audioBuffer);
                }
                [pixelBufferAdaptor.assetWriterInput appendSampleBuffer:videoBuffer];
                CMSampleBufferInvalidate(videoBuffer);
                CFRelease(videoBuffer);
                videoBuffer = nil;
            } else {
                continue;
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [writer finishWritingWithCompletionHandler:^{
                    NSLog(@"Finish \n");
                    
                }];
            });
        }
    });

    while (writer.status == AVAssetWriterStatusWriting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (AVAssetWriterInputMetadataAdaptor *)metadataAdapter {
    NSString *identifier = [kKeySpaceQuickTimeMetadata stringByAppendingFormat:@"/%@",kKeyStillImageTime];
    NSDictionary *spec = @{(id)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier :
                               identifier,
                           (id)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType:
                               @"com.apple.metadata.datatype.int8"   };
    CMFormatDescriptionRef desc;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef _Nonnull)(@[spec]), &desc);
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
- (void)fetchImageMetadataWithOriginalPath:(NSURL *)originalPath targetPath:(NSString *)targetPath assetIdentifier:(NSString *)assetIdentifier {
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:targetPath], kUTTypeJPEG, 1, nil);
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)[NSData dataWithContentsOfFile:originalPath.path], nil);
    NSMutableDictionary *metaData = [(__bridge_transfer  NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) mutableCopy];
    
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setValue:assetIdentifier forKey:kFigAppleMakerNote_AssetIdentifier];
    [metaData setValue:makerNote forKey:(__bridge_transfer  NSString*)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(dest, imageSourceRef, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
}

@end


