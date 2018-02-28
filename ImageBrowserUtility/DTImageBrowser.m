 //
//  DTImageBrowser.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/22.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTImageBrowser.h"
#import "DTImageBrowserAnimator.h"
#import "DTZoomAnimationCoordinator.h"
#import "DTImageBrowserLayout.h"
#import "DTImageBrowserCell.h"
#import "DTLivePhotoCell.h"
#import "DTShadowLayer.h"
#import <Masonry.h>

@interface DTImageBrowserToolView : UIView

@property (nonatomic, strong, readonly) DTShadowLayer* shadowLayer;

@property (nonatomic) DTInnerShadowMask shadowMask;

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong)  UIView *statusDescritionView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, copy) void (^moreHandler)(id sender);
@property (nonatomic, copy) void (^statusDescritionViewHandler)(id sender);

@property (nonatomic, strong) NSString *statusText;

@end

@interface DTImageBrowser () <UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DTImageBrowserLayoutDelegate>

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UIView *relatedView;
@property (nonatomic, strong) DTImageBrowserAnimator *presentationAnimator;
@property (nonatomic, weak)   DTZoomAnimationCoordinator *animatorCoordinator;
@property (nonatomic, strong) UIViewController *presentingVC;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DTImageBrowserLayout *layout;
@property (nonatomic, strong) DTImageBrowserToolView *imageBrowserToolView;

@property (nonatomic) NSNumber *originWindowLevel;

@end

@implementation DTImageBrowserToolView

- (instancetype)initWithFrame:(CGRect)frame withStatus:(NSString *)status {
    self = [super initWithFrame:frame];
    if (self) {
        self.statusText = @"";
        
        self.backgroundColor = [UIColor clearColor];
        
        _shadowLayer = [DTShadowLayer layer];
        [self.layer addSublayer:_shadowLayer];
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreButton.hidden = YES;
    [self addSubview:_moreButton];
    [_moreButton setImage:[UIImage imageNamed:@"ic_photo_more"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(10);
        make.right.mas_equalTo(self.mas_right).offset(-4);
        make.width.height.mas_equalTo(44);
    }];
    _moreButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if (self.statusText.length == 0) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        [self addSubview:_pageControl];
        [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).offset(0);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-24);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(8);
        }];
    } else {
        _statusDescritionView = [[UIView alloc] init];
        _statusDescritionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusDescritionView];
        [_statusDescritionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(0);
            make.right.mas_equalTo(self.mas_right).offset(0);
            make.bottom.mas_equalTo(self.mas_bottom).offset(0);
            make.height.mas_equalTo(44);
        }];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *continerView = [[UIVisualEffectView alloc] initWithEffect:blur];
        continerView.backgroundColor = [UIColor clearColor];
        continerView.userInteractionEnabled = YES;
        [_statusDescritionView addSubview:continerView];
        [continerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:17];
        textLabel.textColor = [UIColor whiteColor];
        self.statusLabel = textLabel;
        [_statusDescritionView addSubview:textLabel];
        
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_statusDescritionView.mas_left).offset(10);
            make.centerY.mas_equalTo(_statusDescritionView.mas_centerY).offset(0);
            make.right.mas_equalTo(_statusDescritionView.mas_right).offset(-20);
        }];
        
        UIImageView *tipView = [[UIImageView alloc] init];
        tipView.userInteractionEnabled = YES;
        tipView.image = [UIImage imageNamed:@"music_arrow"];
        [_statusDescritionView addSubview:tipView];
        [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_statusDescritionView.mas_centerY).offset(0);
            make.right.mas_equalTo(_statusDescritionView.mas_right).offset(-10);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(14);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailVCAction:)];
        [_statusDescritionView addGestureRecognizer:tap];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _shadowLayer.frame = self.layer.bounds;
    _shadowLayer.shadowMask = DTInnerShadowMaskTop;
    _shadowLayer.shadowRadius = 64;
    
    self.statusLabel.text = self.statusText;
}

#pragma -mark Action

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint moreButtonPoint = [self convertPoint:point toView:_moreButton];
    CGPoint statusDescriptionViewPoint = [self convertPoint:point toView:_statusDescritionView];
    if ([_moreButton pointInside:moreButtonPoint withEvent:event]) {
        return _moreButton;
    }
    
    if ([_statusDescritionView pointInside:statusDescriptionViewPoint withEvent:event]) {
        return _statusDescritionView;
    }
    return [super hitTest:point withEvent:event];
}

- (void)moreButtonAction:(UIButton *)sender {
    if(self.moreHandler){
        self.moreHandler(sender);
    }
}

- (void)detailVCAction:(UITapGestureRecognizer *)sender {
    if (self.statusDescritionViewHandler) {
        self.statusDescritionViewHandler(sender);
    }
}

@end

@implementation DTImageBrowser

- (void)dealloc {
    NSLog(@"--DTImageBrowser 释放--");
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self.animatorCoordinator updateCurrentHiddenView:self.relatedView];
}

- (UIView *)relatedView {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:thumbnailImageViewForIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self thumbnailImageViewForIndex:self.currentIndex];
    } else {
        return nil;
    }
}

- (instancetype)initWithPresentingVC:(UIViewController *)presentingVC imageBrowserDelegate:(id<DTImageBrowserDelegate>)imageBrowserDelegate {
    if (self = [super init]) {
        self.presentingVC = presentingVC;
        self.imageBrowserDelegate = imageBrowserDelegate;
        _layout = [[DTImageBrowserLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _imageBrowserToolView = [[DTImageBrowserToolView alloc] initWithFrame:CGRectZero withStatus:nil];
    }
    return self;
}

- (void)showImageBrowserWithIndex:(NSInteger)index withNavgationController:(BOOL)isShow {
    self.currentIndex = index;
    if (isShow) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
        nav.transitioningDelegate = self;
//        self.interactiveNavigationBarHidden = YES;
        nav.modalPresentationStyle = UIModalPresentationCustom;
        [self.presentingVC presentViewController:nav animated:YES completion:nil];
    } else {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        [self.presentingVC presentViewController:self animated:YES completion:nil];
    }
}

- (void)showImageBrowserWithPresentingVC:(UIViewController *)presentingVC imageBrowserDelegate:(id<DTImageBrowserDelegate>)imageBrowserDelegate index:(NSInteger)index {
    DTImageBrowser *imageBrowser = [[DTImageBrowser alloc] initWithPresentingVC:presentingVC imageBrowserDelegate:imageBrowserDelegate];
    [imageBrowser showImageBrowserWithIndex:index withNavgationController:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _layout.minimumLineSpacing = 20;
    _layout.itemSize = self.view.bounds.size;
    _layout.imageBrowserLayoutDelegate = self;
    
    _collectionView.frame = self.view.bounds;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[DTImageBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([DTImageBrowserCell class])];
    [_collectionView registerClass:[DTLivePhotoCell class] forCellWithReuseIdentifier:NSStringFromClass([DTLivePhotoCell class])];
    [self.view addSubview:_collectionView];
    
    _imageBrowserToolView.frame = self.view.bounds;
    [self.view addSubview:_imageBrowserToolView];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO  ];
    [_collectionView layoutIfNeeded];
    
    _imageBrowserToolView.pageControl.currentPage = self.currentIndex;
    
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DTImageBrowserCell class]]) {
        self.presentationAnimator.endView = [(DTImageBrowserCell *)cell imageView];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[(DTImageBrowserCell *)cell imageView].image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        self.presentationAnimator.zoomView = imageView;
    }
    if ([cell isKindOfClass:[DTLivePhotoCell class]]) {
        self.presentationAnimator.endView = [(DTLivePhotoCell *)cell livePhotoView];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[(DTLivePhotoCell *)cell image]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        self.presentationAnimator.zoomView = imageView;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self coverStatusBar:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark 遮挡StatusBar
- (void)coverStatusBar:(BOOL)cover{
    UIWindow *currentWindow = self.view.window ? self.view.window : [[UIApplication sharedApplication] keyWindow];
    if (currentWindow == nil) {
        return;
    }
    
    if (self.originWindowLevel == nil) {
        NSNumber *number = [[NSNumber alloc] initWithFloat:currentWindow.windowLevel];
        self.originWindowLevel = number;
    }
    
    if (cover) {
        if (currentWindow.windowLevel == UIWindowLevelStatusBar + 1) {
            return;
        }
        currentWindow.windowLevel = UIWindowLevelStatusBar + 1;
    } else {
        if (currentWindow.windowLevel == self.originWindowLevel.floatValue) {
            return;
        }
        currentWindow.windowLevel = self.originWindowLevel.floatValue;
    }
}

#pragma -mark WOImageBrowserLayoutDelegate
- (void)currentPageIndexWithIndex:(NSInteger)inidex {
    self.currentIndex = inidex;
    _imageBrowserToolView.pageControl.currentPage = self.currentIndex;
}


#pragma -mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(numberOfPicturesInImageBrowser:)]) {
        _imageBrowserToolView.pageControl.numberOfPages = [self.imageBrowserDelegate numberOfPicturesInImageBrowser:self];
        return [self.imageBrowserDelegate numberOfPicturesInImageBrowser:self];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *image = [self.imageBrowserDelegate imageBrowser:self thumbnailImageForIndex:indexPath.item];
    
    DTImageBrowserCellType cellType = [self imageCellTypeForIndexPath:indexPath];
    if (cellType == DTImageBrowserCellTypeOfStaticPic) {
        DTImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DTImageBrowserCell class]) forIndexPath:indexPath];
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        if (height / width > (ScreenHeight / ScreenWidth) * 1.5) {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }else {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageBrowserCellDelegate = self;
        NSURL *url = [self imageURLForIndexPath:indexPath];
        NSString *path = [self imagePathForIndexPath:indexPath];
        [cell setImageWithImage:image highQualityImageURL:url orFilePath:path withFinishSend:NO];
        return cell;
    } else if (cellType == DTImageBrowserCellTypeOfGif) {
        DTImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DTImageBrowserCell class]) forIndexPath:indexPath];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageBrowserCellDelegate = self;
        NSURL *url = [self imageURLForIndexPath:indexPath];
        NSString *path = [self imagePathForIndexPath:indexPath];
        [cell setImageWithImage:image highQualityImageURL:url orFilePath:path withFinishSend:NO];
        return cell;
    } else {
        DTLivePhotoCell *livePhotoCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DTLivePhotoCell class]) forIndexPath:indexPath];
        NSString *videoPath = [self livePhotoVideoPathForIndexPath:indexPath];
        NSString *imagePath = [self livePhotoCoverImagePathForIndexPath:indexPath];
        livePhotoCell.imageBrowserCellDelegate = self;
        [livePhotoCell setLivePhotoWithImage:image livePhotoVideoURL:nil coverImageURL:nil livePhotoVideoFilePath:videoPath coverImageFilePath:imagePath finishSend:NO];
        return livePhotoCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_imageBrowserToolView setMoreHandler:^(id sender){
        NSLog(@"genduo");
    }];
    
    [_imageBrowserToolView setStatusDescritionViewHandler:^(id sender){
        NSLog(@"xiangqing");
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width + 20;
    //self.currentIndex = round(offsetX / width);
}

- (NSURL *)imageURLForIndexPath:(NSIndexPath *)indexPath {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:highQualityUrlStringForIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self highQualityUrlStringForIndex:indexPath.item];
    } else {
        return nil;
    }
}

- (NSString *)imagePathForIndexPath:(NSIndexPath *)indexPath {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:imagePathForIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self imagePathForIndex:indexPath.item];
    } else {
        return nil;
    }
}

- (DTImageBrowserCellType)imageCellTypeForIndexPath:(NSIndexPath *)indexPath {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:imageBrowserCellTypeForIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self imageBrowserCellTypeForIndex:indexPath.item];
    } else {
        return DTImageBrowserCellTypeOfStaticPic;
    }
}

- (NSString *)livePhotoVideoPathForIndexPath:(NSIndexPath *)indexPath {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:imageBrowserCellLivePhotoVideoPathForIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self imageBrowserCellLivePhotoVideoPathForIndex:indexPath.item];
    } else {
        return nil;
    }
}

- (NSString *)livePhotoCoverImagePathForIndexPath:(NSIndexPath *)indexPath {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:imageBrowserCellLivePhotoCoverImagePathForIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self imageBrowserCellLivePhotoCoverImagePathForIndex:indexPath.item];
    } else {
        return nil;
    }
}

#pragma -mark UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    DTImageBrowserAnimator *animator = [[DTImageBrowserAnimator alloc] initWithStartView:self.relatedView endView:nil zoomView:nil];
    self.presentationAnimator = animator;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UICollectionViewCell *cell = [self.collectionView visibleCells].firstObject;

    if ([cell isKindOfClass:[DTImageBrowserCell class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[(DTImageBrowserCell *)cell imageView].image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        DTImageBrowserAnimator *animator = [[DTImageBrowserAnimator alloc] initWithStartView:[(DTImageBrowserCell *)cell imageView] endView:self.relatedView zoomView:imageView];
        return animator;
    } else if ([cell isKindOfClass:[DTLivePhotoCell class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[(DTLivePhotoCell *)cell image]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        DTImageBrowserAnimator *animator = [[DTImageBrowserAnimator alloc] initWithStartView:[(DTLivePhotoCell *)cell livePhotoView] endView:self.relatedView zoomView:imageView];
        return animator;
    } else {
        return nil;
    }
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    DTZoomAnimationCoordinator *coordinator = [[DTZoomAnimationCoordinator alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    coordinator.currentHiddenView = self.relatedView;
    self.animatorCoordinator = coordinator;
    return coordinator;
}

#pragma -mark WOImageBrowserCellProtocol

- (void)imageBrowserCellDidSingleInCell:(UICollectionViewCell *)imageBrowserCell {
    [self coverStatusBar:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageBrowserCellDidPanInCell:(UICollectionViewCell *)imageBrowserCell scale:(CGFloat)scale {
    CGFloat alpha = scale * scale;
    self.animatorCoordinator.maskView.alpha = alpha;
    [self coverStatusBar:alpha >= 1.0];
}

- (void)imageBrowserCellLongPressInCell:(UICollectionViewCell *)imageBrowserCell image:(UIImage *)image imageData:(NSData *)imageData {
    NSLog(@"长按触发");
}

@end
