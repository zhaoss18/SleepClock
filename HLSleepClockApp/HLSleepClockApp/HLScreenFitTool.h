//
//  HLScreenFitTool.h
//  LianLianApp2
//
//  Created by zss on 2017/5/26.
//  Copyright © 2017年 zss. All rights reserved.
//
/**
 屏幕适配工具
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HLScreenFitTool : NSObject

/**
 宽度适配
 @param width 750屏幕下的宽度
 @return 不同屏幕所需要的尺寸
 */
+ (CGFloat)percentageWidth:(CGFloat)width;

+ (CGFloat)widthFitSize:(CGFloat)iSize;
+ (CGFloat)heightFitSize:(CGFloat)iSize;

@end
