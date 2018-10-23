//
//  KYPathClosestPoint.m
//  CGPathDemo
//
//  Created by HuangKai on 2017/3/20.
//  Copyright © 2017年 HuangKai. All rights reserved.
//

#import "KYPathClosestPoint.h"
#import <YYKit/YYKit.h>
@interface PathCommand : NSObject

@property (nonatomic) CGPathElementType type;
@property (nonatomic, strong) NSValue *point;
@property (nonatomic, strong) NSMutableArray *controlPoints;

@end

@interface KYPathClosestPoint()


@end

@implementation KYPathClosestPoint

- (void)dealloc {
    CGPathRelease(_path);
}

- (void)setPath:(CGPathRef)path {
    CGPathRelease(_path);
    _path = CGPathCreateCopy(path);
    
    [self calculatePoints];
}

//static inline CGFloat CGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
//    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
//}

- (void)calculatePoints {
    NSMutableArray *commands = [NSMutableArray array];
    CGPathApply(self.path, (__bridge void * _Nullable)commands, enumPath);
    
    CGPoint previousPoint = CGPointZero;
    NSInteger piecesCount = commands.count;
    if (piecesCount == 0) {
        return;
    }
    NSInteger index = 0;
    for (PathCommand *command in commands) {
        CGPoint endPoint = [command.point CGPointValue];
        CGPoint startPoint = previousPoint;
        
        CGFloat distance = CGPointGetDistanceToPoint(endPoint, startPoint);
        NSInteger capacityPerPiece = distance/10;
        capacityPerPiece += 1;
//        DLog(@"d:%f, P:%ld", distance, capacityPerPiece);
        
        if (index != 0)  {
            switch (command.type) {
                case kCGPathElementAddLineToPoint: {
                    for (NSInteger i = 0; i < capacityPerPiece; i++) {
                        CGFloat t = ((CGFloat)i) / ((CGFloat)capacityPerPiece);
                        CGPoint point = [self calculateLinear:t p1:startPoint p2:endPoint];
                        [self.points addObject:[NSValue valueWithCGPoint:point]];
                    }
                    break;
                }
                case kCGPathElementMoveToPoint: {
                    break;
                }
                case kCGPathElementAddQuadCurveToPoint: {
                    for (NSInteger i = 0; i < capacityPerPiece; i++) {
                        CGFloat t = ((CGFloat)i) / ((CGFloat)capacityPerPiece);
                        CGPoint point = [self calculateQuad:t p1:startPoint p2:[command.controlPoints[0] CGPointValue] p3:endPoint];
                        [self.points addObject:[NSValue valueWithCGPoint:point]];
                    }
                    break;
                }
                case kCGPathElementAddCurveToPoint: {
                    for (NSInteger i = 0; i < capacityPerPiece; i++) {
                        CGFloat t = ((CGFloat)i) / ((CGFloat)capacityPerPiece);
                        CGPoint point = [self calculateCube:t p1:startPoint p2:[command.controlPoints[0] CGPointValue] p3:[command.controlPoints[1] CGPointValue] p4:endPoint];
                        [self.points addObject:[NSValue valueWithCGPoint:point]];
                    }
                    break;
                }
                case kCGPathElementCloseSubpath: {
                    break;
                }
                default:
                    break;
            }
        }
        previousPoint = endPoint;
        index++;
    }
}

- (CGPoint)calculateLinear:(CGFloat)t p1:(CGPoint)p1 p2:(CGPoint)p2 {
    CGFloat mt = 1 - t;
    CGFloat x = mt*p1.x + t*p2.x;
    CGFloat y = mt*p1.y + t*p2.y;
    return CGPointMake(x, y);
}

- (CGPoint)calculateCube:(CGFloat)t p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
    CGFloat mt = 1 - t;
    CGFloat mt2 = mt*mt;
    CGFloat t2 = t*t;
    
    CGFloat a = mt2*mt;
    CGFloat b = mt2*t*3;
    CGFloat c = mt*t2*3;
    CGFloat d = t*t2;
    
    CGFloat x = a*p1.x + b*p2.x + c*p3.x + d*p4.x;
    CGFloat y = a*p1.y + b*p2.y + c*p3.y + d*p4.y;
    return CGPointMake(x, y);
}

- (CGPoint)calculateQuad:(CGFloat)t p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 {
    CGFloat mt = 1 - t;
    CGFloat mt2 = mt*mt;
    CGFloat t2 = t*t;
    
    CGFloat a = mt2;
    CGFloat b = mt*t*2;
    CGFloat c = t2;
    
    CGFloat x = a*p1.x + b*p2.x + c*p3.x;
    CGFloat y = a*p1.y + b*p2.y + c*p3.y;
    return CGPointMake(x, y);
}

- (NSValue *)findClosestPointOnPath:(CGPoint)point {
    if (self.points.count == 0) {
        return nil;
    }
    NSValue *pointValue = self.points.firstObject;
    CGFloat distance = 0;
    for (NSValue *value in self.points) {
        CGFloat d = CGPointGetDistanceToPoint(point, [value CGPointValue]);
        if (distance == 0 || distance > d) {
            distance = d;
            pointValue = value;
        }
    }
    return pointValue;
}

- (BOOL)isContainPoint:(CGPoint)point distance:(CGFloat)distance {
    if (self.points.count == 0) {
        return NO;
    }
    for (NSValue *value in self.points) {
        if (CGPointGetDistanceToPoint(point, [value CGPointValue]) <= distance) {
            return YES;
        }
    }
    return NO;
}

void enumPath(void *info, const CGPathElement *element)
{
    if (element->type == kCGPathElementCloseSubpath) {
        return;
    }
    NSMutableArray *ma =  (__bridge NSMutableArray*)info;
    
    PathCommand *command = [[PathCommand alloc] init];
    
    NSInteger numberOfPoints = 0;
    switch (element->type) {
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint: // contains 1 point
            numberOfPoints = 1;
            break;
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            numberOfPoints = 2;
            break;
        case kCGPathElementAddCurveToPoint: // contains 3 points
            numberOfPoints = 3;
            break;
        case kCGPathElementCloseSubpath: {
            break;
        }
    }
    
    for (NSInteger index = 0; index < numberOfPoints - 1; index++) {
        CGPoint point = element->points[index];
        NSValue *value = [NSValue valueWithCGPoint:point];
        [command.controlPoints addObject:value];
    }
    command.type = element->type;
    command.point = [NSValue valueWithCGPoint:element->points[numberOfPoints - 1]];
    
    [ma addObject:command];
}

- (NSMutableArray *)points {
    if (!_points) {
        _points = [NSMutableArray array];
    }
    return _points;
}

@end

@implementation PathCommand

- (NSMutableArray *)controlPoints {
    if (!_controlPoints) {
        _controlPoints = [NSMutableArray array];
    }
    return _controlPoints;
}

@end
