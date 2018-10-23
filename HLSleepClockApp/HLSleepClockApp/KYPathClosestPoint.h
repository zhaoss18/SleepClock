//
//  KYPathClosestPoint.h
//  CGPathDemo
//
//  Created by HuangKai on 2017/3/20.
//  Copyright © 2017年 HuangKai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KYPathClosestPoint : NSObject

@property (nonatomic, assign) CGPathRef path;

@property (nonatomic, strong) NSMutableArray *points;


- (NSValue *)findClosestPointOnPath:(CGPoint)point;
- (BOOL)isContainPoint:(CGPoint)point distance:(CGFloat)distance;

@end
