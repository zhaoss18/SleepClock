//
//  UITextView+UIViewUtil.h
//  Greentown
//
//  Created by zss on 14-6-3.
//  Copyright (c) 2014年 DL. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MARGIN (10.0)
@interface UIView (UIViewUtil)

// 获得x坐标
-(CGFloat)x;
// 获得y坐标
-(CGFloat)y;
// 获得宽度
-(CGFloat)width;
// 获得高度
-(CGFloat)height;
// 控件结束位置的x坐标
-(CGFloat)endX; 
// 控件结束位置的y坐标
-(CGFloat)endY;
// 垂直移动，offset代表偏移量，为正是向下偏移，为负是向上偏移
-(void)verticalMove:(CGFloat)offset;
// 水平移动，offset代表偏移量，为正是向右偏移，为负是向左偏移
-(void)horizonMove:(CGFloat)offset;
// 其他属性不变，重新设置高度
-(void)setHeight:(CGFloat)height;
// 其他属性不变，重新设置宽度
-(void)setWidth:(CGFloat)width;
// 其他属性不变，重新设置x坐标
-(void)setOriginX:(CGFloat)x;
// 其他属性不变，重新设置y坐标
-(void)setOriginY:(CGFloat)y;
// 其他属性不变，重新设置x坐标和y坐标
-(void)setOriginWithX:(CGFloat)x andY:(CGFloat)y;
//清除子视图
-(void)clearChildView;
@end
