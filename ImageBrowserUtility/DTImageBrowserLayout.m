//
//  DTImageBrowserLayout.m
//  DTImageBrowser
//
//  Created by dubhe on 2017/5/24.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import "DTImageBrowserLayout.h"

@interface DTImageBrowserLayout ()

@property (nonatomic, assign) CGFloat pageWidth;
@property (nonatomic, assign) NSInteger lastPage;
@property (nonatomic, assign) NSInteger minPage;
@property (nonatomic, assign) NSInteger maxPage;

@end

@implementation DTImageBrowserLayout

- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minPage = 0;
    }
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSInteger page = round(proposedContentOffset.x / self.pageWidth);
    if (velocity.x > 0.2) {
        page += 1;
    } else if (velocity.x < -0.2) {
        page -= 1;
    }
    
    if (page > self.lastPage + 1) {
        page = self.lastPage + 1;
    } else if (page < self.lastPage - 1) {
        page = self.lastPage - 1;
    }
    
    if (page > self.maxPage) {
        page = self.maxPage;
    } else if (page < self.minPage) {
        page = self.minPage;
    }
    self.lastPage = page;
    if ([self.imageBrowserLayoutDelegate respondsToSelector:@selector(currentPageIndexWithIndex:)]) {
         [self.imageBrowserLayoutDelegate currentPageIndexWithIndex:page];
    }
    return CGPointMake(page * self.pageWidth, 0);
}

- (NSInteger)lastPage {
    if (self.collectionView.contentOffset.x < 0) {
        return 0;
    }
    return  round(self.collectionView.contentOffset.x / self.pageWidth);
}

- (NSInteger)maxPage {
    CGFloat contentWidth = self.collectionView.contentSize.width;
    if (contentWidth < 0) {
        return 0;
    } else {
        contentWidth += self.minimumLineSpacing;
        return contentWidth / self.pageWidth - 1;
    }
}

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

@end
