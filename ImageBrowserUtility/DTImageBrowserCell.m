//
//  DTImageBrowserCell.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTImageBrowserCell.h"
#import "DTImageBrowserProgressView.h"

#if 0
#define SLIDE_DOWN_COLSE_IMAGEBROWSER 1
#else
#define SLIDE_DOWN_COLSE_IMAGEBROWSER 0
#endif

@interface DTImageBrowserCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DTImageBrowserProgressView *progressView;

@property (nonatomic, strong) id downloadIdentifier;

@property (nonatomic, strong) UIImage *image;

//手势开始结束的位置
@property (nonatomic, assign) CGRect beginFrame;
@property (nonatomic, assign) CGPoint beginTouch;

@end

@implementation DTImageBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] init];
        [self.contentView addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 2.0f;
//        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.showsHorizontalScrollIndicator =NO;
        
        _imageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_imageView];
        _imageView.clipsToBounds = YES;
        
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

#pragma -mark 设置图片

- (void)setImageWithImage:(UIImage *)image highQualityImageURL:(NSURL *)imageURL orFilePath:(NSString *)path withFinishSend:(BOOL)isSend {

}

#pragma -mark layout

- (void)cellLayout {
    _scrollView.frame = self.contentView.bounds;
    [_scrollView setZoomScale:1.0f animated:NO];
    _imageView.frame = [self fetchFitFrameInScreen];
    _progressView.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
}

- (CGSize)fetchFitSizeInScreen {
    UIImage *image = _imageView.image;
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

#pragma -mark UIGestureRecognizer

- (void)didLongPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan && [self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellLongPressInCell:image:imageData:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellLongPressInCell:self image:_imageView.image imageData:nil];
    }
}

- (void)didDoubleTapAction:(UITapGestureRecognizer *)doubleTap {
    if (_scrollView.zoomScale == 1.0f) {
        CGPoint pointInView = [doubleTap locationInView:_imageView];
        CGFloat w = _scrollView.bounds.size.width / 2.0;
        CGFloat h = _scrollView.bounds.size.height / 2.0;
        CGFloat x = pointInView.x - (w / 2);
        CGFloat y = pointInView.y - (h / 2);
        [_scrollView zoomToRect:CGRectMake(x, y, w, h) animated:true];
    } else {
        [_scrollView setZoomScale:1.0 animated:true];
    }
}

- (void)didSingleTapAction:(UITapGestureRecognizer *)singleTap {
    if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellDidSingleInCell:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellDidSingleInCell:self];
    }
}

- (void)didPanAction:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            self.beginFrame = _imageView.frame;
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
            
            _imageView.frame = CGRectMake(x, y, width, height);
            
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
    BOOL needResetSize = (_imageView.bounds.size.width < size.width || _imageView.bounds.size.height < size.height);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.imageView.center = [self fetchCenterOfContentSize];
        if (needResetSize) {
            weakSelf.imageView.bounds = CGRectMake(0, 0, CGRectGetWidth([self fetchFitFrameInScreen]), CGRectGetHeight([self fetchFitFrameInScreen]));
        }
    }];
}

#pragma -mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _imageView.center = [self fetchCenterOfContentSize];
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
        if (velocity.y < 0 && [self isLongPicture]) {
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

@end
