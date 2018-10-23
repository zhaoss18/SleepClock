//
//  HLSleepColck.m
//  down
//
//  Created by zss on 2018/8/7.
//  Copyright © 2018年 zss. All rights reserved.
//

#import "HLSleepClock.h"
#import "KYPathClosestPoint.h"
#import "UIView+UIViewUtil.h"
#import "hDefine.h"
#import <YYKit/YYKit.h>
@interface HLSleepClock ()

//淡圆环layer
@property (nonatomic, strong) CAShapeLayer *lightGrayLayer;
//大圈的半径
@property (nonatomic, assign) CGFloat aroundRadius;
//刻度数目
@property (nonatomic, assign) NSInteger scaleNumber;
//每个刻度的平均弧度
@property (nonatomic, assign) CGFloat averageAngle;
//刻度盘开始弧度
@property (nonatomic, assign) CGFloat scaleStartAngle;
//刻度盘的半径
@property (nonatomic, assign) CGFloat scaleRadius;
//数字的半径
@property (nonatomic, assign) CGFloat numRadius;
//睡觉时间layer
@property (nonatomic, strong) CAShapeLayer *sleepLayer;
//睡觉路径
@property (nonatomic, strong) UIBezierPath *sleepPath;
//就寝时间
@property (nonatomic, strong) NSDate *startDate;
//起床时间
@property (nonatomic, strong) NSDate *endDate;
//移动数量
@property (nonatomic, assign) NSInteger moveNum;
//每次移动占用的弧度
//就寝按钮
@property (nonatomic, strong) UIButton *btnStart;
//就寝图片
@property (nonatomic, strong) UIImageView *imgvStart;
//就寝按钮所在弧度
@property (nonatomic, assign) CGFloat startAngle;
//起床按钮
@property (nonatomic, strong) UIButton *btnEnd;
//起床图片
@property (nonatomic, strong) UIImageView *imgvEnd;
//起床按钮所在弧度
@property (nonatomic, assign) CGFloat endAngle;
//用来确定以闹钟中心为原点的视图（辅助作用）
@property (nonatomic, strong) UIView *vAssist;
//中间时间的label
@property (nonatomic, strong) UILabel *lblTime;
//滑动后睡觉时间总分钟数
@property (nonatomic, assign) NSInteger minuteDiff;
//用来存储当前移动的button
@property (nonatomic, strong) UIButton *btnMove;
//记录当前屏幕上是否有手势了
@property (nonatomic, assign) BOOL hasGesture;
@property (nonatomic, assign) BOOL moveGesture;
@property (nonatomic, assign) CGFloat endAngle1;
@property (nonatomic, assign) CGFloat startAngle1;
@property (nonatomic, assign) CGPoint startTranslation;
@end
#define pi M_PI

@implementation HLSleepClock

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hasGesture = NO;
        self.scaleNumber = 48;
        self.averageAngle = M_PI * 2 / self.scaleNumber;
        self.scaleStartAngle = M_PI +  M_PI / 3.0 * 2.0;
        self.moveNum = self.scaleNumber * 3;
    }
    return self;
}

- (void)drewViewWithStartTime:(NSDate *)startDate endTime:(NSDate *)endDate {
    
   self.startDate = startDate;
    self.endDate = endDate;
    [self updateSleepLayer];
    [self calculationTime];
    [self updateCicle];
 
}

//根据起始终止时间绘制睡觉圆环，只在第一次赋值的时候使用，后期改变使用另外方法
- (void)updateSleepLayer {
    [self.layer addSublayer:self.sleepLayer];
    self.sleepLayer.fillColor = [UIColor clearColor].CGColor;
    self.sleepLayer.strokeColor = [UIColor colorWithRed:(99.0 / 255.0) green:(104.0 / 255.0) blue:(114.0 / 255.0) alpha:1.0].CGColor;
    self.sleepLayer.lineWidth = self.pathWidth;
    NSDate *endDateS1= [self getYmdDate:self.endDate];
    endDateS1 = [endDateS1 dateByAddingDays:1];
    
   NSTimeInterval startTime = [self.startDate timeIntervalSinceDate:endDateS1];
 NSTimeInterval endTime = [self.endDate timeIntervalSinceDate:endDateS1];
    CGFloat x = 24*60*60*2;
    CGFloat progress1 = 1+ (startTime)/x;
    CGFloat progress2 = 1+ (endTime)/x;
    self.startAngle1 =progress1 *pi*8-pi/2;
    self.endAngle1 = progress2 *pi*8-pi/2;
    self.startAngle = [self getAbs2PiCircleValue:self.startAngle1];
    self.endAngle = [self getAbs2PiCircleValue:self.endAngle1];
    [self updateButtonViewStateWithStartSumAngle:self.startAngle endSumAngle:self.endAngle];
    self.sleepPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.aroundRadius startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    self.sleepLayer.path = self.sleepPath.CGPath;
}

//展示起床和睡觉区域的button
- (void)updateButtonViewStateWithStartSumAngle:(CGFloat)startSumAngle endSumAngle:(CGFloat)endSumAngle {
    
    //起床中心点y值
    CGFloat endY = 0.0;
    //起床中心点x值
    CGFloat endX = 0.0;
    //起床所在象限
    int endIndex = self.endAngle/M_PI_2;
    switch (endIndex) {
        case 0:
            //第一象限
            endY = self.height / 2.0 - cos(endSumAngle) * self.aroundRadius;
            endX = self.height / 2.0 + sin(endSumAngle) * self.aroundRadius;
            break;
        case 1:
            //第二象限
            endY = self.height / 2.0 + sin(endSumAngle-M_PI/2.0) * self.aroundRadius;
            endX = self.height / 2.0 + cos(endSumAngle-M_PI/2.0) * self.aroundRadius;
            break;
        case 2:
            //第三象限
            endY = self.height / 2.0 + cos(endSumAngle-M_PI) * self.aroundRadius;
            endX = self.height / 2.0 - sin(endSumAngle-M_PI) * self.aroundRadius;
            break;
        case 3:
            //第四象限
            endY = self.height / 2.0 - sin(endSumAngle-M_PI*3.0/2.0) * self.aroundRadius;
            endX = self.height / 2.0 - cos(endSumAngle-M_PI*3.0/2.0) * self.aroundRadius;
            break;
        default:
            break;
    }
    //起床按钮位置确定
    [self addSubview:self.btnEnd];
    self.btnEnd.frame = CGRectMake(endX-self.pathWidth/2.0, endY-self.pathWidth/2.0, self.pathWidth, self.pathWidth);
    [self addSubview:self.imgvEnd];
    self.imgvEnd.frame = CGRectMake(self.btnEnd.x+1, self.btnEnd.y+1, self.btnEnd.width-2, self.btnEnd.height-2);
    
    UIBezierPath *endButtonPath = [UIBezierPath bezierPathWithOvalInRect:self.btnEnd.bounds];
    CAShapeLayer *endButtonPathLayer = [CAShapeLayer layer];
    endButtonPathLayer.lineWidth =  (sin(45.0) * self.pathWidth)/2.0;
    endButtonPathLayer.fillColor = [UIColor colorWithRed:(99.0 / 255.0) green:(104.0 / 255.0) blue:(114.0 / 255.0) alpha:1.0].CGColor;
    endButtonPathLayer.path = endButtonPath.CGPath;
    [self.btnEnd.layer addSublayer:endButtonPathLayer];
    //必须要加，因为添加了layer会遮住图片
    [self.btnEnd bringSubviewToFront:self.btnEnd.imageView];
    
    //就寝中心点y值
    CGFloat startY = 0.0;
    //就寝中心点x值
    CGFloat startX = 0.0;
    //就寝时间点所在象限
    int startIndex = self.startAngle/M_PI_2;
    switch (startIndex) {
        case 0:
            //第一象限
            startY = self.height / 2.0 - cos(startSumAngle) * self.aroundRadius;
            startX = self.height / 2.0 + sin(startSumAngle) * self.aroundRadius;
            break;
        case 1:
            //第二象限
            startY = self.height / 2.0 + sin(startSumAngle-M_PI/2.0) * self.aroundRadius;
            startX = self.height / 2.0 + cos(startSumAngle-M_PI/2.0) * self.aroundRadius;
            break;
        case 2:
            //第三象限
            startY = self.height / 2.0 + cos(startSumAngle-M_PI) * self.aroundRadius;
            startX = self.height / 2.0 - sin(startSumAngle-M_PI) * self.aroundRadius;
            break;
        case 3:
            //第四象限
            startY = self.height / 2.0 - sin(startSumAngle-M_PI*3.0/2.0) * self.aroundRadius;
            startX = self.height / 2.0 - cos(startSumAngle-M_PI*3.0/2.0) * self.aroundRadius;
            break;
        default:
            break;
    }
    //就寝按钮位置确定
    [self addSubview:self.btnStart];
    self.btnStart.frame = CGRectMake(startX-self.pathWidth/2.0, startY-self.pathWidth/2.0, self.pathWidth, self.pathWidth);
    [self addSubview:self.imgvStart];
    self.imgvStart.frame = CGRectMake(self.btnStart.x+1, self.btnStart.y+1, self.btnStart.width-2, self.btnStart.height-2);
    
    UIBezierPath *startButtonPath = [UIBezierPath bezierPathWithOvalInRect:self.btnStart.bounds];
    CAShapeLayer *startButtonPathLayer = [CAShapeLayer layer];
    startButtonPathLayer.lineWidth =  (sin(45.0) * self.pathWidth)/2.0;
    startButtonPathLayer.fillColor = [UIColor colorWithRed:(99.0 / 255.0) green:(104.0 / 255.0) blue:(114.0 / 255.0) alpha:1.0].CGColor;
    startButtonPathLayer.path = startButtonPath.CGPath;
    [self.btnStart.layer addSublayer:startButtonPathLayer];
    //必须要加，因为添加了layer会遮住图片
    [self.btnStart bringSubviewToFront:self.btnStart.imageView];
    [self bringSubviewToFront:self.imgvEnd];
    [self bringSubviewToFront:self.imgvStart];
}

- (NSDateComponents *)componentsWithDate:(NSDate *)date {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:date];
    return comps;
}

- (void)updateView {
    
    self.aroundRadius = (self.width-self.pathWidth)/2.0;
    self.scaleRadius = self.aroundRadius - self.pathWidth/2.0 - 14.0;
    self.numRadius = self.scaleRadius - 12.0;
    
    [self addSubview:self.vAssist];
    self.vAssist.frame = CGRectMake(self.width/2.0, self.height/2.0, self.width/2.0, self.height/2.0);
    
    [self updateLightGrayLayer];
    [self drewScale];
    [self updateLableView];
}

//更新最下层的淡色圆环视图
- (void)updateLightGrayLayer {
    
    [self.layer addSublayer:self.lightGrayLayer];
    self.lightGrayLayer.fillColor = [UIColor whiteColor].CGColor;
    self.lightGrayLayer.strokeColor = [UIColor colorWithRed:(239.0 / 255.0) green:(240.0 / 255.0) blue:(241.0 / 255.0) alpha:1.0].CGColor;
    self.lightGrayLayer.lineWidth = self.pathWidth;
    
    
    UIBezierPath *aroundPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.aroundRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
    self.lightGrayLayer.path = aroundPath.CGPath;
}

//画刻度线
- (void)drewScale {
    
    for (int i = 0; i < self.scaleNumber; i++) {
        CGFloat startAngel = self.scaleStartAngle + self.averageAngle*i;
        CGFloat endAngel = startAngel + self.averageAngle / 10.0;//刻度线的宽度
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.scaleRadius startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth =  7.0;
        
        if (i%4 == 0) {
            layer.strokeColor = [UIColor colorWithRed:(65.0 / 255.0) green:(64.0 / 255.0) blue:(59.0 / 255.0) alpha:1.0].CGColor;
            CGPoint point = [self calculateTextPositonWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) Angle:startAngel radius:self.numRadius];
            UILabel *lblNum = [[UILabel alloc]initWithFrame:CGRectMake(point.x-7, point.y-7, 14.0, 14.0)];
            lblNum.text = [NSString stringWithFormat:@"%d",i/4+1];
            lblNum.font = [UIFont systemFontOfSize:10.0];
            lblNum.textColor = [UIColor colorWithRed:(46.0 / 255.0) green:(59.0 / 255.0) blue:(54.0 / 255.0) alpha:1.0];
            lblNum.textAlignment = NSTextAlignmentCenter;
            [self addSubview:lblNum];
        }else{
            layer.strokeColor = [UIColor colorWithRed:(226.0 / 255.0) green:(224.0 / 255.0) blue:(216.0 / 255.0) alpha:1.0].CGColor;
        }
        layer.path = path.CGPath;
        [self.layer addSublayer:layer];
    }
}

//根据半径中心点求出相应弧度上控件的中心
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center Angle:(CGFloat)angel radius:(CGFloat)radius {
    CGFloat x = radius * cosf(angel);
    CGFloat y = radius * sinf(angel);
    return CGPointMake(center.x + x, center.y + y);
}

//确定中间label的位置
- (void)updateLableView {
    
    [self addSubview:self.lblTime];
    CGFloat labelW = (self.scaleRadius - 14.0)*2.0;
    self.lblTime.frame = CGRectMake((self.width-labelW)/2.0, (self.height-self.pathWidth)/2.0, labelW, self.pathWidth);
    
    self.lblTime.attributedText = [self changeLabelWithText:[NSString stringWithFormat:@"%d小时%d分",(int)self.minuteDiff/60,(int)self.minuteDiff%60]];
}

- (NSMutableAttributedString*)changeLabelWithText:(NSString*)needText
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:needText];
    UIFont *font = [UIFont systemFontOfSize:15];
    //找出小时文本位置
    NSRange hourRange = [needText rangeOfString:@"小时"];
    [attrString addAttribute:NSFontAttributeName value:font range:hourRange];
    //找出分文本位置
    NSRange minuteRange = [needText rangeOfString:@"分"];
    [attrString addAttribute:NSFontAttributeName value:font range:minuteRange];
    return attrString;
}




#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
- (CGFloat)getAnglesWithThreePoint:(CGPoint)pointA pointB:(CGPoint)pointB pointC:(CGPoint)pointC {
    
    CGFloat x1 = [self getRotationBetweenLinesCenterX:pointB.x centerY:pointB.y xInView:pointA.x yInView:pointA.y];
    CGFloat x2 = [self getRotationBetweenLinesCenterX:pointB.x centerY:pointB.y xInView:pointC.x yInView:pointC.y];
    CGFloat xx4 = x2-x1;//重4象限切一象限
    if (x1>270&&x2<90) //切换了360度 四象限切到 一二象限
    {
        xx4+=360;
    }
    if (x1<90&&x2>=270)//第一象限跑到第四象限
    {
       xx4 -= 360;
    }
    CGFloat x3 = DEGREES_TO_RADIANS(xx4);
    if (x3>3||x3<-3) {
        
    }
    return x3;
}

- (CGFloat) getRotationBetweenLinesCenterX:(CGFloat)centerX centerY:(CGFloat)centerY  xInView:(CGFloat) xInView yInView: (CGFloat) yInView{
    double rotation = 0;
   
    CGFloat k1 = (CGFloat) (centerY - centerY) / (centerX * 2 - centerX);
    CGFloat k2 = (CGFloat) (yInView - centerY) / (xInView - centerX);
     CGFloat tmpDegree = atan(fabs(k1 - k2)) / (1 + k1 * k2) / pi * 180;
    
    if (xInView > centerX && yInView < centerY) {  //第一象限
         rotation = 90 - tmpDegree;
         //角度统一都多了90度 四象限少了270度 统一都加90度
        rotation+=270;
    } else if (xInView > centerX && yInView > centerY) //第二象限
    {
        rotation =  tmpDegree; //0-90
    } else if (xInView < centerX && yInView > centerY) { //第三象限
        rotation = 180 - tmpDegree;
    } else if (xInView < centerX && yInView < centerY) { //第四象限
         rotation = 180 + tmpDegree;
    } else if (xInView == centerX && yInView < centerY) {
        rotation = 0+270;
    } else if (xInView == centerX && yInView > centerY) {
        rotation = 180-90;
    }
    if (centerY==yInView) {
        if (centerX<xInView)//原点往右是0 往左是 180 modify by zss
        {
            rotation=0;
        }
        else
        {
            rotation=180;
        }
    }
    return  rotation ;
}
- (void)moveButton:(UIButton *)btnMove imageView:(UIImageView *)imgvMove point:(CGPoint)translation {

    //将坐标转换到vAssist，这个视图的左上角的点就是原点
    CGPoint point = [self.vAssist convertPoint:translation fromView:self];
    //为了算弧度的角度
    CGFloat angle = 0;
    //真实的角度
    CGFloat trueAngle = 0;
    CGFloat startY = 0.0;
    CGFloat startX = 0.0;
    if (point.x > 0 && point.y < 0) {
        //第一象限
        trueAngle = M_PI * 2.0 - atan2(-point.y,point.x);
        angle = atan2(-point.y,point.x);
        startY = self.height / 2.0 - sin(angle) * self.aroundRadius;
        startX = self.height / 2.0 + cos(angle) * self.aroundRadius;
    }else if (point.x > 0 && point.y > 0) {
        //第二象限
        trueAngle = atan2(point.y,point.x);
        angle = atan2(point.y,point.x);
        startY = self.height / 2.0 + sin(angle) * self.aroundRadius;
        startX = self.height / 2.0 + cos(angle) * self.aroundRadius;
    }else if (point.x < 0 && point.y > 0) {
        //第三象限
        trueAngle = M_PI - atan2(point.y,-point.x);
        angle = atan2(point.y,-point.x);
        startY = self.height / 2.0 + sin(angle) * self.aroundRadius;
        startX = self.height / 2.0 - cos(angle) * self.aroundRadius;
    }else if (point.x < 0 && point.y < 0) {
        //第四象限
        trueAngle = M_PI + atan2(-point.y,-point.x);
        angle = atan2(-point.y,-point.x);
        startY = self.height / 2.0 - sin(angle) * self.aroundRadius;
        startX = self.height / 2.0 - cos(angle) * self.aroundRadius;
    }else if (point.x == 0) {
        //在y轴上，上下位置
        startX = self.height / 2.0;
        if (point.y < 0) {
            //上面
            trueAngle = M_PI * 3.0 / 2.0;
            startY = self.height / 2.0 - self.aroundRadius;
        }else {
            //下面
            trueAngle = M_PI / 2.0;
            startY = self.height / 2.0 + self.aroundRadius;
        }

    }else if (point.y == 0) {
        //在x轴上，左右位置
        startY = self.height / 2.0;
        if (point.x < 0) {
            //左面
            trueAngle = M_PI;
            startX = self.height / 2.0 - self.aroundRadius;
        }else {
            //右面
            trueAngle = 0;
            startX = self.height / 2.0 + self.aroundRadius;
        }
    }
    CGPoint startCenter  = btnMove.center;
    btnMove.centerX = startX;
    btnMove.centerY = startY;
    imgvMove.centerX = btnMove.centerX;
    imgvMove.centerY = btnMove.centerY;
    CGFloat rr =self.frame.size.width/2;
    //startY startX
    
    //保证开始的位置没有问题
    CGFloat xx = [self getAnglesWithThreePoint:startCenter pointB:CGPointMake(rr,rr) pointC:btnMove.center];
    if (xx==0) {
        return;
    }
    if (btnMove.tag == 11) {
        self.startAngle1 +=xx;
    }
    else
    {
        self.endAngle1+=xx;
    }
    [self calculationTime];
    [self updateCicle];
  
}

- (void)calculationTime
{
    CGFloat endAngle =self.endAngle1;//= ((NSInteger)((self.endAngle1+8*pi*100)*288))/288.0;
    CGFloat startAngle = self.startAngle1; //= ((NSInteger)((self.startAngle1+8*pi*100)*288))/288.0;
    
    CGFloat xxx1 = endAngle-startAngle;
    CGFloat xxx = [self getAbs4PiCircleValue:xxx1];
    self.minuteDiff = ((NSInteger)(xxx/(2*pi)*60*12+4)/5)*5;
    if (self.minuteDiff==0) {
        self.minuteDiff = 720*2;//等于0的时候显示为两天
    }
    
    self.lblTime.attributedText = [self changeLabelWithText:[NSString stringWithFormat:@"%d小时%d分",(int)self.minuteDiff/60,(int)self.minuteDiff%60]];
}


#pragma mark touchesDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.moveGesture = NO;
    if (self.hasGesture == NO) {
        UITouch *touch = touches.anyObject;
        CGPoint translation = [touch locationInView:self];
        CGPoint translation1 = [self.btnStart.layer convertPoint:translation fromLayer:self.layer];
        CGPoint translation2 = [self.btnEnd.layer convertPoint:translation fromLayer:self.layer];
        
        if ([self.btnStart.layer containsPoint:translation1]) {
            self.btnMove = self.btnStart;
            
        }else if ([self.btnEnd.layer containsPoint:translation2]) {
            self.btnMove = self.btnEnd;
        }else
        {
            self.btnMove = [[UIButton alloc] init];
            KYPathClosestPoint *point = [[KYPathClosestPoint alloc] init];
            point.path = self.sleepPath.CGPath;
            if ([point isContainPoint:translation distance:self.sleepLayer.lineWidth/2]) {
                 self.moveGesture = YES;
                self.startTranslation = translation;
            }
            else
            {
                 self.moveGesture = NO;
            }
            
        }
        self.hasGesture = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.hasGesture = NO;
    self.moveGesture = NO;
}

-(CGPoint)getEndPointFrameWithProgress:(float)progress
{
    if (progress<=0.75) {
         progress+=0.25;
    }
    else
    {
       progress-=0.75;
    }
    CGFloat angle = M_PI*2.0*progress;//将进度转换成弧度
    float radius = (self.bounds.size.width-self.imgvEnd.width-2)/2.0;//半径
    int index = (angle)/M_PI_2;//用户区分在第几象限内
    float needAngle = angle - index*M_PI_2;//用于计算正弦/余弦的角度
    float x = 0,y = 0;//用于保存_dotView的frame
    switch (index) {
        case 0:
          //  NSLog(@"第一象限");
            x = radius + sinf(needAngle)*radius;
            y = radius - cosf(needAngle)*radius;
            break;
        case 1:
          //  NSLog(@"第二象限");
            x = radius + cosf(needAngle)*radius;
            y = radius + sinf(needAngle)*radius;
            break;
        case 2:
           // NSLog(@"第三象限");
            x = radius - sinf(needAngle)*radius;
            y = radius + cosf(needAngle)*radius;
            break;
        case 3:
           // NSLog(@"第四象限");
            x = radius - cosf(needAngle)*radius;
            y = radius - sinf(needAngle)*radius;
            break;
        case 4:
            x = radius + sinf(needAngle)*radius;
            y = radius - cosf(needAngle)*radius;
            break;
        default:
            break;
    }
    return  CGPointMake(x, y);
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
        UITouch *touch = touches.anyObject;
        CGPoint translation = [touch locationInView:self];
        if (self.btnMove.tag == 11) {
            [self moveButton:self.btnStart imageView:self.imgvStart point:translation];
        }else if (self.btnMove.tag == 22) {
            [self moveButton:self.btnEnd imageView:self.imgvEnd point:translation];
        }else {
            if (self.moveGesture) {
                 [self setMovePointTranslation:translation];
            }
        }
}

- (void)setMovePointTranslation:(CGPoint)translation
{
    CGFloat rr =self.frame.size.width/2;
    CGFloat xx = [self getAnglesWithThreePoint:self.startTranslation pointB:CGPointMake(rr,rr) pointC:translation];
    if (xx==0) {
        return;
    }
    self.startTranslation = translation;
     self.startAngle1 +=xx;
    self.endAngle1 +=xx;
     [self updateCicle];
}

- (void)updateCicle
{
    self.startAngle = [self getAbs2PiCircleValue:self.startAngle1];
    self.endAngle = [self getAbs2PiCircleValue:self.endAngle1];
    [self changeSleepTimeWithStartAngle:self.startAngle endAngle:self.endAngle];
    CGFloat x1 = self.startAngle/(2*pi);
    CGPoint point = [self getEndPointFrameWithProgress:x1];
    CGRect frame = self.btnStart.frame;
    frame.origin.x = point.x;
    frame.origin.y = point.y;
    self.btnStart.frame = frame;
    self.imgvStart.frame = CGRectMake(self.btnStart.x+1, self.btnStart.y+1, self.btnStart.width-2, self.btnStart.height-2);
    CGFloat   x2 = self.endAngle/(2*pi);
    point = [self getEndPointFrameWithProgress:x2];
    frame = self.btnEnd.frame;
    frame.origin.x = point.x;
    frame.origin.y = point.y;
    self.btnEnd.frame = frame;
    self.imgvEnd.frame = CGRectMake(self.btnEnd.x+1, self.btnEnd.y+1, self.btnEnd.width-2, self.btnStart.height-2);
    NSString *s1 = [[self class ] getNowTimeStr];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate *todayDate = [formatter dateFromString:s1];
    if (self.btnMove ==self.btnEnd)//动了结束按钮
    {
        NSDate *endDate =  [self.startDate dateByAddingMinutes:self.minuteDiff];
        self.endDate = endDate;
       
    }
    else
    {
         if (self.btnMove == self.btnStart) //动了开始按钮
         {
             self.startDate = [self.endDate dateByAddingMinutes:-self.minuteDiff];
        }
        else
        {
            //移动弧度或者开始的时候
            CGFloat   xxxx2 = [self getAbs4PiCircleValue:self.endAngle1]/(4*pi);
            NSInteger  minnuxx = (((NSInteger)(xxxx2*24*60)+4)/5)*5+180;//增加3小时
            self.endDate = [todayDate dateByAddingMinutes:minnuxx];
            self.startDate = [self.endDate dateByAddingMinutes:-self.minuteDiff];
        }
    }
     [self runSelectBlock];
}


/**
 调整时间为有效时间内
 */
- (void)setEffectiveTime
{
    NSString *s1 = [[self class ] getNowTimeStr];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate *todayDate = [formatter dateFromString:s1];
    NSInteger space = [self.endDate timeIntervalSinceDate:todayDate];
    if (space<0) //小于 就是在后面的时间了  这个时候需要
    {
        while (1) {
            self.endDate = [self.endDate dateByAddingDays:1];
            space = [self.endDate timeIntervalSinceDate:todayDate];
            if (space>=0)
            {
                break;
            }
        }
    }//保证起床时间是今天
    else if (space>=86400)//结束时间大于今天 23.55分的时候 需要处理减掉
    {
        //减去天数保证时间有效
        while (1) {
            self.endDate = [self.endDate dateByAddingDays:-1];
            space = [self.endDate timeIntervalSinceDate:todayDate];
            if (space<=86400)
            {
                break;
            }
        }
    }
    self.startDate = [self.endDate dateByAddingMinutes:-self.minuteDiff];
    
}

- (void)runSelectBlock
{
    [self setEffectiveTime];
    NSDate *date1= [self.startDate dateByAddingDays:0];//开始都往前一天
    NSDate *endDateS1= [self getYmdDate:self.endDate];//得到今天的数据
    if ([date1 timeIntervalSinceDate:endDateS1]==0&&self.minuteDiff==1440)//整24小时的时候特殊处理
    {
        date1= [self.startDate dateByAddingDays:-2];
    }
    else
    {
       date1= [self.startDate dateByAddingDays:-1];
    }
    
    if (self.timeChangeBlock) {
        self.timeChangeBlock(date1,self.endDate);
    }
}

- (NSDate*)getYmdDate:(NSDate*)date
{
    NSString *s1 = [[self class ] getNowTimeStr];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
   NSDate *newDate = [formatter dateFromString:s1];
    return newDate;
}

+(NSString*)getNowTimeStr
{
    NSDate *localeDate = [HLSleepClock getLocalDate];
    NSString *dateString=[HLSleepClock stringFromDate1:localeDate strFormat:@"yyyyMMdd"];
    return dateString;
}

+ (NSDate*)getLocalDate
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    interval = 0;//不能处理国际时间
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}


+ (NSString *)stringFromDate1:(NSDate *)date strFormat:(NSString*)strFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:strFormat];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}




/**
 //新绘制睡觉弧圈
 @param startAngle 开始弧度
 @param endAngle 结束弧度
 */
- (void)changeSleepTimeWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    //0到pi的
//    CGFloat startAngleNew = (NSInteger)(startAngle*144)/144.0;
//    CGFloat endAngleNew = (NSInteger)(endAngle*144)/144.0;
    
    CGFloat startAngleNew = startAngle;
    CGFloat endAngleNew = endAngle;
    startAngle = startAngleNew;
    endAngle = endAngleNew;
    CGFloat x = fabs(endAngle-startAngle);//弧度
    if ((NSInteger)(startAngle*100000) == (NSInteger)(endAngle*100000)||x<1/144.0) {
        self.sleepPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.aroundRadius startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];//12小时 24小时都整个圈
        
    }else {
        self.sleepPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.aroundRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    }
    self.sleepLayer.path = self.sleepPath.CGPath;
}

#pragma mark setter and getter method
- (void)setPathWidth:(CGFloat)pathWidth {
    _pathWidth = pathWidth;
    [self updateView];
}

- (CAShapeLayer *)lightGrayLayer {
    if (_lightGrayLayer == nil) {
        _lightGrayLayer = [[CAShapeLayer alloc] init];
    }
    return _lightGrayLayer;
}

- (CAShapeLayer *)sleepLayer {
    if (_sleepLayer == nil) {
        _sleepLayer = [[CAShapeLayer alloc] init];
    }
    return _sleepLayer;
}

- (UIBezierPath *)sleepPath {
    if (_sleepPath == nil) {
        _sleepPath = [UIBezierPath bezierPath];
    }
    return _sleepPath;
}

- (UIButton *)btnStart {
    if (_btnStart == nil) {
        _btnStart = [[UIButton alloc] init];
        [_btnStart setImageEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        _btnStart.exclusiveTouch = YES;
        _btnStart.userInteractionEnabled = NO;
        _btnStart.tag = 11;
    }
    return _btnStart;
}

- (UIImageView *)imgvStart {
    if (_imgvStart == nil) {
        _imgvStart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_s_icon"]];
    }
    return _imgvStart;
}

- (UIButton *)btnEnd {
    if (_btnEnd == nil) {
        _btnEnd = [[UIButton alloc] init];
        [_btnEnd setImageEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        //为了防止两个按钮同时都可以动设置的属性
        _btnEnd.exclusiveTouch = YES;
        _btnEnd.userInteractionEnabled = NO;
        _btnEnd.tag = 22;
    }
    return _btnEnd;
}

- (UIImageView *)imgvEnd {
    if (_imgvEnd == nil) {
        _imgvEnd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_m_icon"]];
    }
    return _imgvEnd;
}

- (UIView *)vAssist {
    if (_vAssist == nil) {
        _vAssist = [[UIView alloc] init];
    }
    return _vAssist;
}

- (UILabel *)lblTime {
    if (_lblTime == nil) {
        _lblTime = [[UILabel alloc] init];
        _lblTime.textAlignment = NSTextAlignmentCenter;
        _lblTime.textColor = [UIColor colorWithRed:(65.0 / 255.0) green:(64.0 / 255.0) blue:(59.0 / 255.0) alpha:1.0];
        _lblTime.font = [UIFont systemFontOfSize:30.0];
        _lblTime.text = @"00小时00分";
    }
    return _lblTime;
}

- (UIButton *)btnMove {
    if (_btnMove == nil) {
        _btnMove = [[UIButton alloc] init];
    }
    return _btnMove;
}


#pragma mark 计算 周期数据方法
/**
 获取一天的周期数据
 
 @param 输入值
 @return 返回值0到2pi两个圈的数值
 */
-(CGFloat)getAbs2PiCircleValue:(CGFloat)value
{
    if (value<0) {
        while (1) {
            value = value+2*pi;
            if (value>=0) {
                return value;
            }
        }
    }
    else if(value>pi*2)
    {
        while (1) {
            value = value-2*pi;
            if (value<2*pi) {
                return value;
            }
        }
    }
    return value;
}

/**
 获取一天的周期数据
 @param 输入值
 @return 返回值0到4pi两个圈的数值
 */
- (CGFloat)getAbs4PiCircleValue:(CGFloat)value
{
    if (value<=0) {
        while (1) {
            value = value+4*pi;
            if (value>=0) {
                return value;
            }
        }
    }
    else if(value>pi*4)
    {
        while (1) {
            value = value-4*pi;
            if (value<4*pi) {
                return value;
            }
        }
    }
    return value;
}

@end
