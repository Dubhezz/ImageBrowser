//
//  DTImageBrowser.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/22.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, DTImageBrowserCellType) {
    DTImageBrowserCellTypeOfStaticPic,
    DTImageBrowserCellTypeOfGif,
    DTImageBrowserCellTypeOfLivePhoto
};

@class DTImageBrowser;

@protocol DTImageBrowserDelegate <NSObject>

/**
 返回图片个数
 */
- (NSInteger)numberOfPicturesInImageBrowser:(DTImageBrowser *)imageBrowser;

/**
 返回timeline占位图，没有返回nil
 */
- (UIImage *)imageBrowser:(DTImageBrowser *)imageBrowser thumbnailImageForIndex:(NSInteger)index;

/**
 返回占位图所在的View（cell）,拖动时设置hidden属性
 */
- (UIView *)imageBrowser:(DTImageBrowser *)imageBrowser thumbnailImageViewForIndex:(NSInteger)index;

/**
 返回一般清晰度图片URL（无PicGroup结构）
 */
- (NSURL *)imageBrowser:(DTImageBrowser *)imageBrowser normalQualityUrlStringForIndex:(NSInteger)index;

/**
 返回一般高清图片URL（无PicGroup结构)
 */
- (NSURL *)imageBrowser:(DTImageBrowser *)imageBrowser highQualityUrlStringForIndex:(NSInteger)index;

/**
 未发送时，返回图片本地路径
 */
- (NSString *)imageBrowser:(DTImageBrowser *)imageBrowser imagePathForIndex:(NSInteger)index;

/**
 返回picGroup结构（timeline)
 */
- (id)ImageBrowser:(DTImageBrowser *)imageBrowser picGroupForIndex:(NSInteger)index;

/**
 返回cell的类型（静态图片，动图，livePhoto）
 */
- (DTImageBrowserCellType)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellTypeForIndex:(NSInteger)index;

/**
 返回Video本地路径
 */
- (NSString *)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellLivePhotoVideoPathForIndex:(NSInteger)index;

/**
 返回coverImage本地路径
 */
- (NSString *)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellLivePhotoCoverImagePathForIndex:(NSInteger)index;

@end

@protocol DTImageBrowserPageControlDelegate <NSObject>

/**
    取pageControl,只取一次
 */
- (UIView *)pageControlOfImageBrowser:(DTImageBrowser *)imageBrowser;

/**
    添加到父视图上调用
 */
- (void)imageBrowserPageControl:(UIView *)pageControl  didMoveToSuperView:(UIView *)view;

/**
    pageControl布局是调用
 */
- (void)imageBrowserPageControl:(UIView *)pageControl needLayoutInSuperView:(UIView *)view;
/**
    页码变更时调用
 */
- (void)imageBroeserPageControl:(UIView *)pageControl didChangeCurrentPage:(NSInteger)currentPage;

@end

@interface DTImageBrowser : UIViewController

@property (nonatomic, weak) id<DTImageBrowserDelegate> imageBrowserDelegate;
@property (nonatomic, weak) id<DTImageBrowserPageControlDelegate> imagePageControlDelegate;
@property (nonatomic, assign) CGFloat imageSpacing;

- (instancetype)initWithPresentingVC:(UIViewController *)presentingVC imageBrowserDelegate:(id<DTImageBrowserDelegate>)imageBrowserDelegate;
- (void)showImageBrowserWithIndex:(NSInteger)index withNavgationController:(BOOL)isShow;

@end
