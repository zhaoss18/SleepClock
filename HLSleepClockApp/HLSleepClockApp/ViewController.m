//
//  ViewController.m
//  HLSleepClockApp
//
//  Created by 赵少松 on 2018/10/23.
//  Copyright © 2018年 HL. All rights reserved.
//

#import "ViewController.h"
#import "HLSleepClock.h"
#import "hDefine.h"
#import <YYKit/YYKit.h>
@interface ViewController ()
@property (nonatomic, strong) HLSleepClock *sleepClock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.sleepClock];
    
    NSString *currentDateStr = [[NSDate date] stringWithFormat:@"yyy-MM-dd"];
    NSDate *endDateTime = [NSDate dateWithString:[currentDateStr stringByAppendingString:@" 06:00:00"] format:@"yyy-MM-dd HH:mm:ss"];
    NSDate *beginDateTime = [endDateTime initWithTimeInterval:(-60 * 60 * 8) sinceDate:endDateTime];

        [self.sleepClock drewViewWithStartTime:beginDateTime endTime:endDateTime];
    // Do any additional setup after loading the view.
}


- (HLSleepClock *)sleepClock {
    if (_sleepClock == nil) {
        CGFloat widthDif = HLSizeW(100); //HLSizeW(65.f+10);
        _sleepClock = [[HLSleepClock alloc] initWithFrame:CGRectMake(widthDif / 2.f, kFullScreenSize.height - HLSizeW(146.f) - (kFullScreenWidth - widthDif), (kFullScreenWidth - widthDif), kFullScreenWidth - widthDif)];
        _sleepClock.pathWidth = HLSizeW(35.0);
        __weak ViewController *weak_self = self;
        [_sleepClock setTimeChangeBlock:^(NSDate *startDate, NSDate *endDate) {
            
            [weak_self kUpDateHeadView:startDate end:endDate isFirst:NO];
            [weak_self updateSubmitData:startDate endDate:endDate updated:NO isFirst:NO];
        }];
    }
    return _sleepClock;
}
- (void)kUpDateHeadView:(NSDate *)startDate end:(NSDate *)endDate isFirst:(BOOL)isFirst
{
    
}

- (void)updateSubmitData:(NSDate *)startDate endDate:(NSDate *)endDate updated:(BOOL)isUpdate isFirst:(BOOL)isFirst
{
    
}

@end
