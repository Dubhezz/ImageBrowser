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

@interface DTImageView : UIImageView

@property (nonatomic, copy) void (^imageViewDidTapBlock)(NSUInteger index);
@property (nonatomic, assign) NSUInteger index;
@end

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

#pragma -mark DTImageBrowserDelegate
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
