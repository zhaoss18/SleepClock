//
//  UITextView+UIViewUtil.h
//  Greentown
//
//  Created by 赵少松 on 14-6-3.
//  Copyright (c) 2014年 DL. All rights reserved.
//

#import "UIView+UIViewUtil.h"

@implementation UIView (UIViewUtil)

// 获得x坐标
-(CGFloat)x{
    return self.frame.origin.x;
}
// 获得y坐标
-(CGFloat)y{
    return self.frame.origin.y;
}
// 获得宽度
-(CGFloat)width{
    return self.frame.size.width;
}
// 获得高度
-(CGFloat)height{
    return self.frame.size.height;
}

// view的结束坐标
-(CGFloat)endX {
    return  self.frame.origin.x + self.frame.size.width;
}

// view的结束坐标
-(CGFloat)endY {
    return  self.frame.origin.y + self.frame.size.height;
}

// 水平移动，offset代表偏移量，为正是向右偏移，为负是向左偏移
- (void)horizonMove:(CGFloat)offset {
    self.frame = CGRectMake(self.frame.origin.x + offset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
// 垂直移动，offset代表偏移量，为正是向下偏移，为负是向上偏移
- (void)verticalMove:(CGFloat)offset {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + offset, self.frame.size.width, self.frame.size.height);
}
// 其他属性不变，重新设置高度
-(void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}
// 其他属性不变，重新设置宽度
-(void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}
// 其他属性不变，重新设置x坐标
-(void)setOriginX:(CGFloat)x {
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
// 其他属性不变，重新设置y坐标
-(void)setOriginY:(CGFloat)y {
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}
// 其他属性不变，重新设置x坐标和y坐标
-(void)setOriginWithX:(CGFloat)x andY:(CGFloat)y {
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

-(void)clearChildView
{
    if (self) {
        for(UIView *subv in [self subviews])
        {
            [subv removeFromSuperview];
        }
        
    }
}

@end
