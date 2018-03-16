//
//  ViewController.m
//  ImageBrowser
//
//  Created by dubhe on 2018/2/27.
//  Copyright © 2018年 Dubhe. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "DTImageBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import <OOMDetector/OOMDetector.h>
#import "DTNetworkDownloader.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <PhotosUI/PHLivePhotoView.h>
#import "DTLivePhotoDownLoadManager.h"

@interface DTSmallImageView : UIImageView

@property (nonatomic, copy) void (^imageViewDidTapBlock)(NSUInteger index);
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSURL *imageURL;
- (void)loadImageWithImageURL:(NSURL *)URL;

@end

@implementation DTSmallImageView

- (instancetype)initWithImage:(UIImage *)image index:(NSUInteger)index {
    self = [super initWithImage:image];
    if (self) {
        self.index = index;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)loadImageWithImageURL:(NSURL *)URL {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:URL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_sync(dispatch_get_main_queue(), ^{
//            if ([self.delegate respondsToSelector:@selector(DTImageViewImageLoading:progress:)]) {
//                [self.delegate DTImageViewImageLoading:self progress:receivedSize/(CGFloat)expectedSize];
//            }
        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            self.image = image;
//            if ([self.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
//                [self.delegate DTImageViewImageDidLoad:image progress:1];
//            }
        }
    }];
}

- (void)imageViewDidTap:(UITapGestureRecognizer *)tap {
    if (self.imageViewDidTapBlock) {
        self.imageViewDidTapBlock(self.index);
    }
}




@end

@interface ViewController () <DTImageBrowserDelegate>

@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, strong) NSArray <UIImage *>* placeholderImages;
@property (nonatomic, strong) NSArray <DTSmallImageView *>*imageViews;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, strong) AVURLAsset *asset;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *clearCacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearCacheButton setTitle:@"清除缓存" forState:UIControlStateNormal];
    [clearCacheButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearCacheButton addTarget:self action:@selector(clearCacheButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearCacheButton];
    [clearCacheButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *checkLeakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkLeakeButton setTitle:@"检查是否有内存泄漏" forState:UIControlStateNormal];
    [checkLeakeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [checkLeakeButton addTarget:self action:@selector(checkLeake:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkLeakeButton];
    [checkLeakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(90);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(30);
    }];
    
    DTSmallImageView *imageView0 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1000.jpg"] index:0];
    DTSmallImageView *imageView1 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1001.jpg"] index:1];
    DTSmallImageView *imageView2 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1002.jpg"] index:2];
    DTSmallImageView *imageView3 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1003.jpg"] index:3];
    DTSmallImageView *imageView4 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1004.jpg"] index:4];
    DTSmallImageView *imageView5 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1009.jpg"] index:5];
    DTSmallImageView *imageView6 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1006.jpg"] index:6];
    DTSmallImageView *imageView7 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1007.jpg"] index:7];
    DTSmallImageView *imageView8 = [[DTSmallImageView alloc] initWithImage:[UIImage imageNamed:@"1008.jpg"] index:8];
    NSArray <NSURL *>*imageURLs = @[[NSURL URLWithString:@"https://wx3.sinaimg.cn/or480/006agIs1ly1fp4dfwxfr3j30u01hc0xm.jpg"],
                                    [NSURL URLWithString:@"https://wx1.sinaimg.cn/or480/006agIs1ly1fp4dfw7serj30u01hck1d.jpg"],
                                    [NSURL URLWithString:@"https://wx4.sinaimg.cn/or480/006agIs1ly1fp4dfx8itlj30u01hcjy4.jpg"],
                                    [NSURL URLWithString:@"https://wx4.sinaimg.cn/or480/006agIs1ly1fp4dfvvpj8j30u01hcgsr.jpg"],
                                    [NSURL URLWithString:@"https://wx1.sinaimg.cn/or480/006agIs1ly1fp4dfy0rytj30mi14044g.jpg"],
                                    [NSURL URLWithString:@"https://wx3.sinaimg.cn/or480/006agIs1ly1fp4dfwlly0j30tz1hc7lt.jpg"],
                                    [NSURL URLWithString:@"https://wx2.sinaimg.cn/or480/006agIs1ly1fp4dfxhvpcj30hs0vkjvm.jpg"],
                                    [NSURL URLWithString:@"https://wx1.sinaimg.cn/or480/006agIs1ly1fp4diculgej30eo0nogns.jpg"],
                                    [NSURL URLWithString:@"https://wx4.sinaimg.cn/or480/006agIs1ly1fp4dfvh7hnj30u01hc0xm.jpg"]];
//    NSArray <NSURL*>*imageURLs = @[[NSURL URLWithString:@"https://wx3.sinaimg.cn/or480/6a162bf9ly1fori4rxrr2g20c80c8wui.gif"],
//                                   [NSURL URLWithString:@"https://wx1.sinaimg.cn/or480/6a162bf9ly1fori4sl5f8g20c80c8js8.gif"],
//                                   [NSURL URLWithString:@"https://wx4.sinaimg.cn/or480/6a162bf9ly1fori53ym5eg20c80c8b16.gif"],
//                                   [NSURL URLWithString:@"https://wx4.sinaimg.cn/or480/6a162bf9ly1fori5557o8g20dw09qb29.gif"],
//                                   [NSURL URLWithString:@"https://wx1.sinaimg.cn/or480/6a162bf9ly1fori4wbzp0g20c80c8u10.gif"],
//                                   [NSURL URLWithString:@"https://wx3.sinaimg.cn/or480/6a162bf9ly1fori4xslchg20c80b4hdt.gif"],
//                                   [NSURL URLWithString:@"https://wx2.sinaimg.cn/or480/6a162bf9ly1fori4ycvfxg20b40b443v.gif"],
//                                   [NSURL URLWithString:@"https://wx1.sinaimg.cn/or480/6a162bf9ly1fori501q68g20c80c8b2b.gif"],
//                                   [NSURL URLWithString:@"https://wx4.sinaimg.cn/or480/6a162bf9ly1fori51620dg20c80c8qoz.gif"]
//                                   ];
    [imageView0 sd_setImageWithURL:imageURLs[0]];
    [imageView1 sd_setImageWithURL:imageURLs[1]];
    [imageView2 sd_setImageWithURL:imageURLs[2]];
    [imageView3 sd_setImageWithURL:imageURLs[3]];
    [imageView4 sd_setImageWithURL:imageURLs[4]];
    [imageView5 sd_setImageWithURL:imageURLs[5]];
    [imageView6 sd_setImageWithURL:imageURLs[6]];
    [imageView7 sd_setImageWithURL:imageURLs[7]];
    [imageView8 sd_setImageWithURL:imageURLs[8]];
    
    
    NSArray <DTSmallImageView *>*imageViews = @[
                                           imageView0,
                                           imageView1,
                                           imageView2,
                                           imageView3,
                                           imageView4,
                                           imageView5,
                                           imageView6,
                                           imageView7,
                                           imageView8
                                           ];
    self.imageViews = imageViews;
    
    NSArray <UIImage *>*placeholderImages = @[
                                             [UIImage imageNamed:@"1000.jpg"],
                                             [UIImage imageNamed:@"1001.jpg"],
                                             [UIImage imageNamed:@"1002.jpg"],
                                             [UIImage imageNamed:@"1003.jpg"],
                                             [UIImage imageNamed:@"1004.jpg"],
                                             [UIImage imageNamed:@"1009.jpg"],
                                             [UIImage imageNamed:@"1006.jpg"],
                                             [UIImage imageNamed:@"1007.jpg"],
                                             [UIImage imageNamed:@"1008.jpg"]
                                             ];
    self.placeholderImages = placeholderImages;
    
    for (DTSmallImageView *imageView in imageViews) {
        [imageView setImageViewDidTapBlock:^(NSUInteger index) {
            [self imageViewDidTapWithIndex:index];
        }];
    }
    
    NSArray <UIImageView *>*imageViews1 = @[ imageView0,
                                             imageView1,
                                             imageView2
                                           ];
    NSArray <UIImageView *>*imageViews2 = @[ imageView3,
                                             imageView4,
                                             imageView5
                                           ];
    
    NSArray <UIImageView *>*imageViews3 = @[ imageView6,
                                             imageView7,
                                             imageView8
                                           ];
    
    UIStackView *subStackView1 = [[UIStackView alloc] initWithArrangedSubviews:imageViews1];
    subStackView1.axis = UILayoutConstraintAxisHorizontal;
    subStackView1.distribution = UIStackViewDistributionFillEqually;
    subStackView1.spacing = 5;
    UIStackView *subStackView2 = [[UIStackView alloc] initWithArrangedSubviews:imageViews2];
    subStackView2.axis = UILayoutConstraintAxisHorizontal;
    subStackView2.distribution = UIStackViewDistributionFillEqually;
    subStackView2.spacing = 5;
    UIStackView *subStackView3 = [[UIStackView alloc] initWithArrangedSubviews:imageViews3];
    subStackView3.axis = UILayoutConstraintAxisHorizontal;
    subStackView3.distribution = UIStackViewDistributionFillEqually;
    subStackView3.spacing = 5;
    
    UIStackView *contentStackView = [[UIStackView alloc] initWithArrangedSubviews:@[subStackView1, subStackView2, subStackView3]];
    contentStackView.axis = UILayoutConstraintAxisVertical;
    contentStackView.distribution = UIStackViewDistributionFillEqually;
    contentStackView.spacing = 5;
    self.contentStackView = contentStackView;
    [self.view addSubview:contentStackView];
    [contentStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
        make.centerY.equalTo(self.view.mas_centerY).offset(0);
        make.width.height.mas_equalTo(self.view.bounds.size.width - 10);
    }];
    self.contentStackView.backgroundColor = [UIColor redColor];
    
    
    __weak typeof(self) weakSelf = self;
//    [[[DTNetworkDownloader alloc] init] dataWithURLString:@"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F000TdSzojx07iI15hxVl010f0100t3cT0k01.mov" progress:^(NSURL *videoURL, float progress) {
//        NSLog(@"--------- %@ ------------", @(progress));
//    } completion:^(NSURL *fileURL, NSURL *videoURL, NSData *data, NSError *error) {
//        NSLog(@"完成 ---- %@---", fileURL);
//    }];
    
//    NSString *imageURLString = @"https://wx2.sinaimg.cn/woriginal/006agIs1ly1fp4dfwxfr3j30u01hc0xm.jpg";
//    NSString *videoURLString = @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F000TdSzojx07iI15hxVl010f0100t3cT0k01.mov";
//
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
//                      stringByAppendingPathComponent:@"movs/"];
//    [[NSFileManager defaultManager] createDirectoryAtPath:path
//                              withIntermediateDirectories:true
//                                               attributes:nil
//                                                    error:nil];
//    NSString *identifier = [[NSUUID UUID] UUIDString];
//    NSString *videoTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[NSString MD5:identifier]]];
//
//    NSString *imageTargetPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString MD5:identifier]]];
//
//    [[[DTLivePhotoDownLoadManager alloc] init] downloadeVideoWithVideoURLString:videoURLString imageURLString:imageURLString imageTargetPath:imageTargetPath videoTargetPath:videoTargetPath  assetIdentifier:identifier mergeProgress:^(NSURL * _Nullable originalVideoURL, float progress) {
//        NSLog(@"-- %@ ---- %@ --",@(progress),originalVideoURL);
//    } callBack:^(NSString * _Nullable videoFilePath, NSString * _Nullable imageFilePath, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"生成livePhoto失败");
//        } else {
//            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//            if (status == PHAuthorizationStatusDenied) {
//                NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No permission to access the album" message:[NSString stringWithFormat:@"You can enter the system settings>privacy>camera to allow %@ access to your camera", app_Name] preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"I Know" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    [alertController dismissViewControllerAnimated:YES completion:nil];
//                }];
//                UIAlertAction *nextAction = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                    if ([[UIApplication sharedApplication] canOpenURL:url])
//                    {
//                        [[UIApplication sharedApplication] openURL:url];
//                    }
//                }];
//                [alertController addAction:cancelAction];
//                [alertController addAction:nextAction];
//                [self presentViewController:alertController animated:YES completion:nil];
//            } else if (imageFilePath.length > 0 && videoFilePath.length > 0) {
//
//
//                NSURL *photoURL = [NSURL fileURLWithPath:imageFilePath];//@"...picture.jpg"
//                NSURL *videoURL = [NSURL fileURLWithPath:videoFilePath];//@"...video.mov"
//
//                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                    PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
//                    [request addResourceWithType:PHAssetResourceTypePhoto
//                                         fileURL:photoURL
//                                         options:nil];
//                    [request addResourceWithType:PHAssetResourceTypePairedVideo
//                                         fileURL:videoURL
//                                         options:nil];
//
//                } completionHandler:^(BOOL success,
//                                      NSError * _Nullable error) {
//                    if (success) {
//                        NSLog(@"LivePhotos 已经保存至相册!");
//
//                    } else {
//                        NSLog(@"error: %@",error);
//                    }
//                }];
//
//
//            } else {
//                NSLog(@"保存失败");
//            }
//        }
//    }];

}

- (void)imageViewDidTapWithIndex:(NSUInteger)index {
    DTImageBrowser *imageBroser = [[DTImageBrowser alloc] initWithPresentingVC:self imageBrowserDelegate:self];
    [imageBroser showImageBrowserWithIndex:index withNavgationController:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearCacheButtonDidTap:(UIButton *)sender {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSLog(@"缓存已清除");
    }];
}


#pragma -mark DTImageBrowserDelegate
- (NSURL *)imageBrowser:(DTImageBrowser *)imageBrowser highQualityUrlStringForIndex:(NSInteger)index {
    //780db7d6gy1fl5tz89n1cj21jk2bck6q
    //780db7d6gy1fl5tzaxe5xj21kw2dcqv6
    //780db7d6gy1fl5tz9ugvej21kw2awb29
    //780db7d6gy1fl5tz9rbadj21kw28l7wh
    //780db7d6gy1fl5tz8c0ywj21jj1wzhdt
    //780db7d6gy1fl5tzab608j21kw2aqqv5
    //780db7d6gy1fl5u0bha26j21jf26ue82
    //780db7d6gy1fl5u0a8mguj21kw2dhb29
    //780db7d6gy1fl5u09mt0yj219t1tuh7n780db7d6gy1fl5u09mt0yj219t1tuh7n
    
    //d2f2e96egy1fnkiabq09fj20b40b4gmt
    //d2f2e96egy1fnkiabmppnj20b40b474q
    //d2f2e96egy1fnkiabooh6j20b40b4wfs
    //d2f2e96egy1fnkiabpgvaj20b40b4myl
    //d2f2e96egy1fnkiabpi0fj20b40b4dh8
    //d2f2e96egy1fnkiabqxrkj20b40b4wfd
    //d2f2e96egy1fnkiabrirjj20b40b4ta1
    //d2f2e96egy1fnkiabmvigj20b40b4aag
    //d2f2e96egy1fnkiabtfv1j20b40b4abh
    
    //@"https://wx3.sinaimg.cn/large/6a162bf9ly1fori4rxrr2g20c80c8wui.gif"
    //@"https://wx1.sinaimg.cn/large/6a162bf9ly1fori4sl5f8g20c80c8js8.gif"
    //@"https://wx4.sinaimg.cn/large/6a162bf9ly1fori53ym5eg20c80c8b16.gif"
    //@"https://wx4.sinaimg.cn/large/6a162bf9ly1fori5557o8g20dw09qb29.gif"
    //@"https://wx1.sinaimg.cn/large/6a162bf9ly1fori4wbzp0g20c80c8u10.gif"
    //@"https://wx3.sinaimg.cn/large/6a162bf9ly1fori4xslchg20c80b4hdt.gif"
    //@"https://wx2.sinaimg.cn/large/6a162bf9ly1fori4ycvfxg20b40b443v.gif"
    //@"https://wx1.sinaimg.cn/large/6a162bf9ly1fori501q68g20c80c8b2b.gif"
    //@"https://wx4.sinaimg.cn/large/6a162bf9ly1fori51620dg20c80c8qoz.gif"
    
    //https://wx3.sinaimg.cn/woriginal/6a162bf9ly1fori4rxrr2g20c80c8wui.gif
    //https://wx1.sinaimg.cn/woriginal/6a162bf9ly1fori4sl5f8g20c80c8js8.gif
    //https://wx4.sinaimg.cn/woriginal/6a162bf9ly1fori53ym5eg20c80c8b16.gif
    //https://wx4.sinaimg.cn/woriginal/6a162bf9ly1fori5557o8g20dw09qb29.gif
    //https://wx1.sinaimg.cn/woriginal/6a162bf9ly1fori4wbzp0g20c80c8u10.gif
    //https://wx3.sinaimg.cn/woriginal/6a162bf9ly1fori4xslchg20c80b4hdt.gif
    //https://wx2.sinaimg.cn/woriginal/6a162bf9ly1fori4ycvfxg20b40b443v.gif
    //https://wx1.sinaimg.cn/woriginal/6a162bf9ly1fori501q68g20c80c8b2b.gif
    //https://wx4.sinaimg.cn/woriginal/6a162bf9ly1fori51620dg20c80c8qoz.gif
    
    //livePhoto
    //cover1  https://wx2.sinaimg.cn/woriginal/006agIs1ly1fp4dfwxfr3j30u01hc0xm.jpg
    //cover2  https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfw7serj30u01hck1d.jpg
    //cover3  https://wx4.sinaimg.cn/woriginal/006agIs1ly1fp4dfx8itlj30u01hcjy4.jpg
    //cover4  https://wx2.sinaimg.cn/woriginal/006agIs1ly1fp4dfvvpj8j30u01hcgsr.jpg
    //cover5  https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfy0rytj30mi14044g.jpg
    //cover6  https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfwlly0j30tz1hc7lt.jpg
    //cover7  https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfxhvpcj30hs0vkjvm.jpg
    //cover8  https://wx3.sinaimg.cn/woriginal/006agIs1ly1fp4diculgej30eo0nogns.jpg
    //cover9  https://wx3.sinaimg.cn/woriginal/006agIs1ly1fp4dfvh7hnj30u01hc0xm.jpg
    
    //video1  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F000TdSzojx07iI15hxVl010f0100t3cT0k01.mov
    //video2  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F000Rk0CHjx07iI15QebC010f01010mDc0k01.mov
    //video3  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F001YlYYGjx07iI1671mT010f0100t2fM0k01.mov
    //video4  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F002xruUBjx07iI16zJFd010f0100YtVd0k01.mov
    //video5  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F003PhNHXjx07iI16RSve010f0100oSMP0k01.mov
    //video6  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F002XPypjjx07iI1717DW010f0100ieHb0k01.mov
    //video7  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F002JcgKMjx07iI14Z848010f0101eurf0k01.mov
    //video8  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F0030Zpahjx07iI17pV4A010f0100zhHR0k01.mov
    //video9  http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F001YlYYGjx07iI17FYJh010f0100t2fM0k01.mov
    
    NSArray <NSURL*>*imageURLs = @[[NSURL URLWithString:@"https://wx3.sinaimg.cn/large/6a162bf9ly1fori4rxrr2g20c80c8wui.gif"],
                                   [NSURL URLWithString:@"https://wx1.sinaimg.cn/large/6a162bf9ly1fori4sl5f8g20c80c8js8.gif"],
                                   [NSURL URLWithString:@"https://wx4.sinaimg.cn/large/6a162bf9ly1fori53ym5eg20c80c8b16.gif"],
                                   [NSURL URLWithString:@"https://wx4.sinaimg.cn/large/6a162bf9ly1fori5557o8g20dw09qb29.gif"],
                                   [NSURL URLWithString:@"https://wx1.sinaimg.cn/large/6a162bf9ly1fori4wbzp0g20c80c8u10.gif"],
                                   [NSURL URLWithString:@"https://wx3.sinaimg.cn/large/6a162bf9ly1fori4xslchg20c80b4hdt.gif"],
                                   [NSURL URLWithString:@"https://wx2.sinaimg.cn/large/6a162bf9ly1fori4ycvfxg20b40b443v.gif"],
                                   [NSURL URLWithString:@"https://wx1.sinaimg.cn/large/6a162bf9ly1fori501q68g20c80c8b2b.gif"],
                                   [NSURL URLWithString:@"https://wx4.sinaimg.cn/large/6a162bf9ly1fori51620dg20c80c8qoz.gif"]
                                   ];
    return imageURLs[index];
}

- (NSString *)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellLivePhotoCoverImagePathForIndex:(NSInteger)index {
    NSArray <NSString *> *livePhotoCoverImages = @[ @"https://wx2.sinaimg.cn/woriginal/006agIs1ly1fp4dfwxfr3j30u01hc0xm.jpg",
                                                    @"https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfw7serj30u01hck1d.jpg",
                                                    @"https://wx4.sinaimg.cn/woriginal/006agIs1ly1fp4dfx8itlj30u01hcjy4.jpg",
                                                    @"https://wx2.sinaimg.cn/woriginal/006agIs1ly1fp4dfvvpj8j30u01hcgsr.jpg",
                                                    @"https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfy0rytj30mi14044g.jpg",
                                                    @"https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfwlly0j30tz1hc7lt.jpg",
                                                    @"https://wx1.sinaimg.cn/woriginal/006agIs1ly1fp4dfxhvpcj30hs0vkjvm.jpg",
                                                    @"https://wx3.sinaimg.cn/woriginal/006agIs1ly1fp4diculgej30eo0nogns.jpg",
                                                    @"https://wx3.sinaimg.cn/woriginal/006agIs1ly1fp4dfvh7hnj30u01hc0xm.jpg"
                                                    ];
    return livePhotoCoverImages[index];
}

- (NSString *)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellLivePhotoVideoPathForIndex:(NSInteger)index {
    NSArray <NSString *> *videoURLStrings = @[ @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F000TdSzojx07iI15hxVl010f0100t3cT0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F000Rk0CHjx07iI15QebC010f01010mDc0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F001YlYYGjx07iI1671mT010f0100t2fM0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F002xruUBjx07iI16zJFd010f0100YtVd0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F003PhNHXjx07iI16RSve010f0100oSMP0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F002XPypjjx07iI1717DW010f0100ieHb0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F002JcgKMjx07iI14Z848010f0101eurf0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F0030Zpahjx07iI17pV4A010f0100zhHR0k01.mov",
                                               @"http://video.weibo.com/media/play?livephoto=http%3A%2F%2Fus.sinaimg.cn%2F001YlYYGjx07iI17FYJh010f0100t2fM0k01.mov"
                                              ];
    return videoURLStrings[index];
}

- (NSInteger)numberOfPicturesInImageBrowser:(DTImageBrowser *)imageBrowser {
    return self.imageViews.count;
}

//- (UIImage *)imageBrowser:(DTImageBrowser *)imageBrowser thumbnailImageForIndex:(NSInteger)index {
//
//    return self.placeholderImages[index];
//}

- (UIView *)imageBrowser:(DTImageBrowser *)imageBrowser thumbnailImageViewForIndex:(NSInteger)index {
    return self.imageViews[index];
}

- (DTImageBrowserCellType)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellTypeForIndex:(NSInteger)index {
    return DTImageBrowserCellTypeOfLivePhoto;
}


- (void)checkLeake:(UIButton *)sender {
    if (![[OOMDetector getInstance].currentLeakChecker isStackLogging]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你尚未开启内存泄漏监控" message:@"如需开启内存泄漏监控，请使用OOMDetector类提供的相关api进行设置。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self showIndicator:YES];
    [[OOMDetector getInstance] executeLeakCheck:^(NSString *leakStack, size_t total_num){
        NSLog(@"--------------------------------%zu--------------------------------------------",total_num);

        NSLog(leakStack);

        NSLog(@"----------------------------------------------------------------------------");
        [self showIndicator:NO];
    }];
}

- (void)showIndicator:(BOOL)yn
{
    if (!self.indicator) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color = [UIColor lightGrayColor];
        self.indicator = indicator;
        self.indicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    }
    self.indicator.hidden = !yn;
    if (yn) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.indicator];
        [self.indicator startAnimating];
    } else {
        [self.indicator stopAnimating];
        [self.indicator removeFromSuperview];
    }
}




@end


