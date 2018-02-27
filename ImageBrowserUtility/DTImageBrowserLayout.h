//
//  DTImageBrowserLayout.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTImageBrowserLayoutDelegate <NSObject>

- (void)currentPageIndexWithIndex:(NSInteger)inidex;

@end

@interface DTImageBrowserLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<DTImageBrowserLayoutDelegate> imageBrowserLayoutDelegate;

@end
