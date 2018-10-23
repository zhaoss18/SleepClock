//
//  HLSleepColck.h
//  down
//
//  Created by zss on 2018/8/7.
//  Copyright © 2018年 zss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLSleepClock : UIControl

//环形宽度
@property (nonatomic, assign) CGFloat pathWidth;

//传入就寝和起床时间
- (void)drewViewWithStartTime:(NSDate *)startDate endTime:(NSDate *)endDate;
@property (nonatomic,copy) void(^timeChangeBlock)(NSDate *startDate,NSDate *endDate);
@end
