//
//  DTImageBrowserCell.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTImageBrowserCellProtocol.h"

@interface DTImageBrowserCell : UICollectionViewCell <DTImageBrowserCellProtocol>

@property (nonatomic, weak) id<DTImageBrowserCellProtocol> imageBrowserCellDelegate;

@property (nonatomic, strong) UIImageView *imageView;

- (void)setImageWithImage:(UIImage *)image highQualityImageURL:(NSURL *)imageURL orFilePath:(NSString *)path withFinishSend:(BOOL)isSend;

@end
