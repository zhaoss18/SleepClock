//
//  HLScreenFitTool.m
//  LianLianApp2
//
//  Created by zss on 2017/5/26.
//  Copyright © 2017年 zss. All rights reserved.
//

#import "HLScreenFitTool.h"

//屏幕大小
#define kHLFullScreenHeight [UIScreen mainScreen].bounds.size.height
#define kHLFullScreenWidth  [UIScreen mainScreen].bounds.size.width

@implementation HLScreenFitTool

+ (CGFloat)percentageWidth:(CGFloat)width {
    return [HLScreenFitTool widthFitSize:width];
}

+ (CGFloat)widthFitSize:(CGFloat)iSize {
    return ((kHLFullScreenWidth / 375.0) * iSize);
}

+ (CGFloat)heightFitSize:(CGFloat)iSize {
    return ((kHLFullScreenHeight / 667.0) * iSize);
}

@end
