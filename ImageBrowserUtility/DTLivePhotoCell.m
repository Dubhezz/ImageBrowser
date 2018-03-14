//
//  DTLivePhotoCell.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/6/5.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTLivePhotoCell.h"
#import "DTImageBrowserProgressView.h"


#if 0
#define SLIDE_DOWN_COLSE_IMAGEBROWSER 1
#else
#define SLIDE_DOWN_COLSE_IMAGEBROWSER 0
#endif

@interface DTLivePhotoCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DTImageBrowserProgressView *progressView;

//手势开始结束的位置
@property (nonatomic, assign) CGRect beginFrame;
@property (nonatomic, assign) CGPoint beginTouch;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic) PHLivePhotoRequestID requsetID;

@end

@implementation DTLivePhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] init];
        [self.contentView addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 2.0f;
        //        _scrollView.showsVerticalScrollIndicator = NO;
        //        _scrollView.showsHorizontalScrollIndicator =NO;
        
        _livePhotoView = [[PHLivePhotoView alloc] init];
        [_scrollView addSubview:_livePhotoView];
        _livePhotoView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.progressView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAction:)];
        [self.contentView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTapAction:)];
        [self.contentView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanAction:)];
        pan.delegate = self;
        [_scrollView addGestureRecognizer:pan];
    }
    return self;
}

- (void)setLivePhotoWithImage:(UIImage *)image livePhotoVideoURL:(NSURL *)videoURL coverImageURL:(NSURL *)imageURL livePhotoVideoFilePath:(NSString *)videoFilePath coverImageFilePath:(NSString *)imagePath finishSend:(BOOL)isSend {
    __weak typeof(self) weakSelf = self;
    self.image = image;
    [self cellLayout];
    self.livePhotoView.frame = [self fetchFitFrameInScreen];
    
//    if () {
    
        NSArray *urlArray = @[
                              [NSURL fileURLWithPath:@"/var/mobile/Containers/Data/Application/7362ACD1-DC6E-445E-ACFD-005E7221BFAC/Library/Caches/movs/77bba09cde268cb81ba8df423b07bd89.mov"],
                              [NSURL fileURLWithPath:@"/var/mobile/Containers/Data/Application/7362ACD1-DC6E-445E-ACFD-005E7221BFAC/Library/Caches/default/com.hackemist.SDWebImageCache.default/c355e7f6487b14ab726f25bba6e9d360.jpg"]
                              ];
    
        [PHLivePhoto requestLivePhotoWithResourceFileURLs:urlArray placeholderImage:image targetSize:[self fetchFitSizeInScreen] contentMode:PHImageContentModeAspectFit resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
            [weakSelf cellLayout];
            weakSelf.livePhotoView.livePhoto = livePhoto;
            weakSelf.livePhotoView.frame = [weakSelf fetchFitFrameInScreen];
        }];
//    } else {
//        //先从缓存中获取
//
//    }
}

#pragma -mark layout

- (void)cellLayout {
    _scrollView.frame = self.contentView.bounds;
    [_scrollView setZoomScale:1.0f animated:NO];
    _livePhotoView.frame = [self fetchFitFrameInScreen];
    _progressView.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
}

- (CGSize)fetchFitSizeInScreen {
    UIImage *image = self.image;//_livePhotoView.image;
    if (!image) {
        return CGSizeZero;
    }
    CGFloat scale = image.size.height / image.size.width;
    CGFloat width = _scrollView.bounds.size.width;
    CGFloat height = scale * width;
    return CGSizeMake(width, height);
}

- (CGRect)fetchFitFrameInScreen {
    CGSize size = [self fetchFitSizeInScreen];
    CGFloat y = _scrollView.bounds.size.height - size.height > 0 ? (_scrollView.bounds.size.height - size.height) * 0.5 : 0;
    return CGRectMake(0, y, size.width, size.height);
}

- (CGPoint)fetchCenterOfContentSize {
    //图片两边的留白
    CGFloat detalWidth = self.bounds.size.width - _scrollView.contentSize.width;
    CGFloat offsetX = detalWidth > 0 ? detalWidth * 0.5 : 0;
    CGFloat detalHeight = self.bounds.size.height - _scrollView.contentSize.height;
    CGFloat offsetY = detalHeight > 0 ? detalHeight * 0.5 : 0;
    return CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma -mark Action

- (void)didLongPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan && [self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellLongPressInCell:image:imageData:)]) {
        //[self.imageBrowserCellDelegate imageBrowserCellLongPressInCell:self image:_imageView.image imageData:nil];
    }
}

- (void)didDoubleTapAction:(UITapGestureRecognizer *)doubleTap {
    if (_scrollView.zoomScale == 1.0f) {
        CGPoint pointInView = [doubleTap locationInView:_livePhotoView];
        CGFloat w = _scrollView.bounds.size.width / 2.0;
        CGFloat h = _scrollView.bounds.size.height / 2.0;
        CGFloat x = pointInView.x - (w / 2);
        CGFloat y = pointInView.y - (h / 2);
        [_scrollView zoomToRect:CGRectMake(x, y, w, h) animated:true];
    } else {
        [_scrollView setZoomScale:1.0 animated:true];
    }

}

- (void)didSingleTapAction:(UITapGestureRecognizer *)sender {
    if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellDidSingleInCell:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellDidSingleInCell:self];
    }
}

- (void)didPanAction:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            self.beginFrame = _livePhotoView.frame;
            self.beginTouch = [pan locationInView:_scrollView];
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            CGPoint translation = [pan translationInView:_scrollView];
            CGPoint currentTouch = [pan locationInView:_scrollView];
#if SLIDE_DOWN_COLSE_IMAGEBROWSER
            CGFloat scale = MIN(1.0, MAX(0.5, 1 - translation.y / self.bounds.size.height));
#else
            CGFloat scale = MIN(1.0, MAX(0.5, 1 - fabs(translation.y) / self.bounds.size.height));
#endif
            CGFloat width = self.beginFrame.size.width * scale;
            CGFloat height = self.beginFrame.size.height * scale;
            
            CGFloat xRate = (self.beginTouch.x - self.beginFrame.origin.x) / self.beginFrame.size.width;
            CGFloat currentTouchDeltaX = xRate * width;
            CGFloat x = currentTouch.x - currentTouchDeltaX;
            
            CGFloat yRate = (self.beginTouch.y - self.beginFrame.origin.y) / self.beginFrame.size.height;
            CGFloat currentTouchDeltaY = yRate *height;
            CGFloat y = currentTouch.y - currentTouchDeltaY;
            
            _livePhotoView.frame = CGRectMake(x, y, width, height);
            
            if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellDidPanInCell:scale:)]) {
                [self.imageBrowserCellDelegate imageBrowserCellDidPanInCell:self scale:scale];
            }
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [pan velocityInView:self];
#if SLIDE_DOWN_COLSE_IMAGEBROWSER
            if (velocity.y > 0) {
                [self didSingleTapAction:nil];
            } else {
                [self endPanAction];
            }
#else
            if (fabs(velocity.y) > 0) {
                [self didSingleTapAction:nil];
            } else {
                [self endPanAction];
            }
#endif
        }
            
            break;
            
        default:
            [self endPanAction];
            break;
    }
}

- (void)endPanAction {
    if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellDidPanInCell:scale:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellDidPanInCell:self scale:1.0];
    }
    
    CGSize size = [self fetchFitSizeInScreen];
    BOOL needResetSize = (_livePhotoView.bounds.size.width < size.width || _livePhotoView.bounds.size.height < size.height);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.livePhotoView.center = [self fetchCenterOfContentSize];
        if (needResetSize) {
            weakSelf.livePhotoView.bounds = CGRectMake(0, 0, CGRectGetWidth([self fetchFitFrameInScreen]), CGRectGetHeight([self fetchFitFrameInScreen]));
        }
    }];
}

#pragma -mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _livePhotoView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _livePhotoView.center = [self fetchCenterOfContentSize];
}

#pragma -mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [pan velocityInView:self];
#if SLIDE_DOWN_COLSE_IMAGEBROWSER
        if (velocity.y < 0) {
            return NO;
        }
        if (fabs(velocity.x) > velocity.y) {
            return NO;
        }
#else
        if (fabs(velocity.x) > fabs(velocity.y)) {
            return NO;
        }
#endif
        if (_scrollView.contentOffset.y > 0) {
            return NO;
        }
        return YES;
    }
    return YES;
}

- (BOOL)isLongPicture {
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    if (height / width > (ScreenHeight / ScreenWidth) * 1.5) {
        return YES;
    } else {
        return NO;
    }
}

#pragma -mark lazy load
- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[DTImageBrowserProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}

#pragma -mark livePhoto

- (NSArray *)getAllFileByPath:(NSString *)path withFileName:(NSString *)name{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *urlArray = [NSMutableArray array];
    for (NSString * fileName in array){
        if ([fileName containsString:name]) {
            NSString *path = [NSString stringWithFormat:@"%@%@",[self filePath],fileName];
            [urlArray addObject:[NSURL fileURLWithPath:path]];
        }
    }
    return urlArray;
}

- (NSString *)filePath {
    return nil;
}

- (NSString *)fileNameWithVideoURLString:(NSString *)videoURLString {
    return nil;
}

- (void)loadLivePhotoWithVideoFilePath:(NSString *)videoPath withImage:(UIImage *)image videoURLString:(NSString *)videoURLString {
    

}

@end
