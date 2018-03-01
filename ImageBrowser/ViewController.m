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


//@interface DTImageView : UIImageView
//@property (nonatomic, weak) id<DTImageViewDelegate> delegate;
//@property (nonatomic, copy) void (^imageViewDidTapBlock)(NSUInteger index);
//@property (nonatomic, assign) NSUInteger index;
//@property (nonatomic, strong) NSString *imageURLString;
//@end

@implementation DTImageView

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
            if ([self.delegate respondsToSelector:@selector(DTImageViewImageLoading:progress:)]) {
                [self.delegate DTImageViewImageLoading:self progress:receivedSize/(CGFloat)expectedSize];
            }
        });
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            if ([self.delegate respondsToSelector:@selector(DTImageViewImageDidLoad:progress:)]) {
                [self.delegate DTImageViewImageDidLoad:image progress:1];
            }
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
@property (nonatomic, strong) NSArray <DTImageView *>*imageViews;
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
    
    DTImageView *imageView0 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1000.jpg"] index:0];
    DTImageView *imageView1 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1001.jpg"] index:1];
    DTImageView *imageView2 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1002.jpg"] index:2];
    DTImageView *imageView3 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1003.jpg"] index:3];
    DTImageView *imageView4 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1004.jpg"] index:4];
    DTImageView *imageView5 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1009.jpg"] index:5];
    DTImageView *imageView6 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1006.jpg"] index:6];
    DTImageView *imageView7 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1007.jpg"] index:7];
    DTImageView *imageView8 = [[DTImageView alloc] initWithImage:[UIImage imageNamed:@"1008.jpg"] index:8];
    
    NSArray <DTImageView *>*imageViews = @[
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
    
    for (DTImageView *imageView in imageViews) {
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
    //780db7d6gy1fl5u09mt0yj219t1tuh7n
    
    //d2f2e96egy1fnkiabq09fj20b40b4gmt
    //d2f2e96egy1fnkiabmppnj20b40b474q
    //d2f2e96egy1fnkiabooh6j20b40b4wfs
    //d2f2e96egy1fnkiabpgvaj20b40b4myl
    //d2f2e96egy1fnkiabpi0fj20b40b4dh8
    //d2f2e96egy1fnkiabqxrkj20b40b4wfd
    //d2f2e96egy1fnkiabrirjj20b40b4ta1
    //d2f2e96egy1fnkiabmvigj20b40b4aag
    //d2f2e96egy1fnkiabtfv1j20b40b4abh
    
    //https://wx3.sinaimg.cn/woriginal/6a162bf9ly1fori4rxrr2g20c80c8wui.gif
    //https://wx1.sinaimg.cn/woriginal/6a162bf9ly1fori4sl5f8g20c80c8js8.gif
    //https://wx4.sinaimg.cn/woriginal/6a162bf9ly1fori53ym5eg20c80c8b16.gif
    //https://wx4.sinaimg.cn/woriginal/6a162bf9ly1fori5557o8g20dw09qb29.gif
    //https://wx1.sinaimg.cn/woriginal/6a162bf9ly1fori4wbzp0g20c80c8u10.gif
    //https://wx3.sinaimg.cn/woriginal/6a162bf9ly1fori4xslchg20c80b4hdt.gif
    //https://wx2.sinaimg.cn/woriginal/6a162bf9ly1fori4ycvfxg20b40b443v.gif
    //https://wx1.sinaimg.cn/woriginal/6a162bf9ly1fori501q68g20c80c8b2b.gif
    //https://wx4.sinaimg.cn/woriginal/6a162bf9ly1fori51620dg20c80c8qoz.gif
    
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

- (NSInteger)numberOfPicturesInImageBrowser:(DTImageBrowser *)imageBrowser {
    return self.imageViews.count;
}

- (UIImage *)imageBrowser:(DTImageBrowser *)imageBrowser thumbnailImageForIndex:(NSInteger)index {

    return self.placeholderImages[index];
}

- (UIView *)imageBrowser:(DTImageBrowser *)imageBrowser thumbnailImageViewForIndex:(NSInteger)index {
    return self.imageViews[index];
}

- (DTImageBrowserCellType)imageBrowser:(DTImageBrowser *)imageBrowser imageBrowserCellTypeForIndex:(NSInteger)index {
    return DTImageBrowserCellTypeOfStaticPic;
}


@end
