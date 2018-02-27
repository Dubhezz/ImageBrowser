//
//  DTImageBrowserCellProtocol.h
//  
//
//  Created by dubhe on 2017/6/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DTImageBrowserCellProtocol <NSObject>

- (void)imageBrowserCellDidSingleInCell:(UICollectionViewCell *)imageBrowserCell;

- (void)imageBrowserCellDidPanInCell:(UICollectionViewCell *)imageBrowserCell scale:(CGFloat)scale;

- (void)imageBrowserCellLongPressInCell:(UICollectionViewCell *)imageBrowserCell image:(UIImage *)image imageData:(NSData *)imageData;

@end
