//
//  DTShadowLayer.h
//  DTImageBrowser
//
//  Created by dubhe on 2017/6/5.
//  Copyright © 2017年 dubhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    DTInnerShadowMaskNone       = 0,
    DTInnerShadowMaskTop        = 1 << 1,
    DTInnerShadowMaskBottom     = 1 << 2,
    DTInnerShadowMaskLeft       = 1 << 3,
    DTInnerShadowMaskRight      = 1 << 4,
    DTInnerShadowMaskVertical   = DTInnerShadowMaskTop | DTInnerShadowMaskBottom,
    DTInnerShadowMaskHorizontal = DTInnerShadowMaskLeft | DTInnerShadowMaskRight,
    DTInnerShadowMaskAll        = DTInnerShadowMaskVertical | DTInnerShadowMaskHorizontal
} DTInnerShadowMask;

@interface DTShadowLayer : CAShapeLayer

@property (nonatomic) DTInnerShadowMask shadowMask;

@end
