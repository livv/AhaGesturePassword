//
//  AhaGesturePasswordView.m
//  AhaGesturePasswordDemo
//
//  Created by wei on 15/11/30.
//  Copyright © 2015年 livv. All rights reserved.
//

#import "AhaGesturePasswordView.h"

typedef NS_ENUM(NSInteger, AhaPointState) {
    AhaPointStateNormal,
    AhaPointStateSelect
};

@interface AhaPoint : NSObject

@property (nonatomic, assign) AhaPointState state;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGPoint center;

@end


@implementation AhaPoint



@end


@interface AhaGesturePasswordView ()
{
    CGFloat _diameter;
    CGFloat _radius;
}

@property (nonatomic, strong) NSMutableArray * selectPoints;
@property (nonatomic, strong) NSMutableArray * points;
@property (nonatomic, assign) CGPoint currentPoint;

@end


@implementation AhaGesturePasswordView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupWithFrame:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupWithFrame:self.frame];
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame {
    
    self.backgroundColor = [UIColor clearColor];
    
    self.lineWidth = 3;
    self.circleLineWidth = 2;
    self.tintAlpha = 0.4f;
    self.smallCircleRatio = 0.3;
    self.normalTintColor = [UIColor whiteColor];
    self.selectTintColor = [UIColor whiteColor];
    self.errorTintColor = [UIColor redColor];
    

    [self.points removeAllObjects];
    
    for (int i = 0; i < 9; i ++) {
        
        AhaPoint * point = [[AhaPoint alloc] init];
        point.state = AhaPointStateNormal;
        point.index = i;
        
        [self.points addObject:point];
    }
    
}


- (void)drawRect:(CGRect)rect {

    [self drawLine:rect];
    [self drawPoint:rect];
    
}

- (void)drawPoint:(CGRect)rect {
    
    float interval = (MIN(rect.size.width, rect.size.height)) / 13;
    _diameter = interval * 3;
    _radius = _diameter * 0.5f;
    
    
    for (int i = 0; i < 9; i ++) {
        
        int row = i / 3;
        int list = i % 3;


        CGRect frame = CGRectMake(list * ( interval + _diameter ) + interval,
                                  row * ( interval + _diameter ) + interval,
                                  _diameter,
                                  _diameter);


        AhaPoint * ahaPoint = [self.points objectAtIndex:i];
        ahaPoint.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        
        
        //大圆
        {
            switch (ahaPoint.state) {
                case AhaPointStateNormal:
                    [[UIColor clearColor] setFill];
                    break;
                case AhaPointStateSelect:
                    if (_isError) {
                        [[self.errorTintColor colorWithAlphaComponent:self.tintAlpha] setFill];
                    } else {
                        [[self.selectTintColor colorWithAlphaComponent:self.tintAlpha] setFill];
                    }
                    break;
            }
            
            CGContextFillEllipseInRect(context, CGRectMake(ahaPoint.center.x - _radius,
                                                           ahaPoint.center.y - _radius,
                                                           _diameter,
                                                           _diameter));
        }
        
        //圆圈
        {
            CGContextAddEllipseInRect(context, frame);
            switch (ahaPoint.state) {
                case AhaPointStateNormal:
                    [self.normalTintColor setStroke];
                    break;
                case AhaPointStateSelect:
                    if (_isError) {
                        [self.errorTintColor setStroke];
                    } else {
                        [self.selectTintColor setStroke];
                    }
                    break;
            }
            CGContextSetLineWidth(context, self.circleLineWidth);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
        //圆点
        {
            if (ahaPoint.state == AhaPointStateSelect) {
                
                if (_isError) {
                    [self.errorTintColor setFill];
                } else {
                    [self.selectTintColor setFill];
                }
                CGContextFillEllipseInRect(context, CGRectMake(ahaPoint.center.x - _diameter * self.smallCircleRatio * .5,
                                                               ahaPoint.center.y - _diameter * self.smallCircleRatio * .5,
                                                               _diameter * self.smallCircleRatio,
                                                               _diameter * self.smallCircleRatio));
            }
        }
        
    }

}

- (void)drawLine:(CGRect)rect {
    
    if (self.selectPoints.count == 0) {
        return;
    }
    
    UIBezierPath *path;
    
    path = [UIBezierPath bezierPath];
    path.lineWidth = self.lineWidth;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    
    if (_isError) {
        [self.errorTintColor set];
    } else {
        [self.selectTintColor set];
    }
    
    for (int i = 0; i < self.selectPoints.count; i ++) {
        AhaPoint * point = self.selectPoints[i];
        
        if (i == 0) {
            [path moveToPoint:point.center];
        } else {
            [path addLineToPoint:point.center];
        }
    }
    
    [path addLineToPoint:self.currentPoint];
    [path stroke];
}


#pragma mark - touch 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    
    [self reset];
    
    _currentPoint = point;
    
    for (AhaPoint *ahaPoint in self.points) {
        if ([self distanceFromPoint:_currentPoint toPoint:ahaPoint.center] < _radius) {
            ahaPoint.state = AhaPointStateSelect;
            if (![self.selectPoints containsObject:ahaPoint]) {
                [self.selectPoints addObject:ahaPoint];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    _currentPoint = point;
    
    for (AhaPoint *ahaPoint in self.points) {
        
        if ([self distanceFromPoint:_currentPoint toPoint:ahaPoint.center] < _radius) {
            
            if (![self.selectPoints containsObject:ahaPoint]) {
                ahaPoint.state = AhaPointStateSelect;
                [self.selectPoints addObject:ahaPoint];
            }
            break;
        }
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self outputPwd];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self outputPwd];
    [self setNeedsDisplay];
}


#pragma mark - helpers

- (void)outputPwd {
    
    AhaPoint *ahaPoint = [self.selectPoints lastObject];
    _currentPoint = ahaPoint.center;
    
    //获取结果
    NSMutableString *pwd = [[NSMutableString alloc]initWithCapacity:0];
    for (int i = 0; i < self.selectPoints.count; i ++) {
        AhaPoint *ahaPoint = self.selectPoints[i];
        [pwd appendFormat:@"%ld", (long)ahaPoint.index];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ahaGesturePasswordView:password:)]) {
        [self.delegate ahaGesturePasswordView:self password:pwd];
    }
}

- (void)reset {
    
    _isError = NO;
    
    for (AhaPoint * point in self.selectPoints) {
        point.state = AhaPointStateNormal;
    }
    [self.selectPoints removeAllObjects];
    [self setNeedsDisplay];
    
}

- (void)setError {
    _isError = YES;
    [self setNeedsDisplay];
}


- (CGFloat)distanceFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    
    CGFloat distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    return distance;
}


#pragma mark - CGContext使用
//画未选中点图片
- (UIImage *)drawUnselectImageWithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] setStroke];
    CGContextSetLineWidth(context, 5);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *unselectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return unselectImage;
}

//画选中点图片
- (UIImage *)drawSelectImageWithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5);
    
    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
    
    UIColor *selectColor = self.selectTintColor;
    
    [selectColor set];
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    
    [selectColor setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

//画错误图片
- (UIImage *)drawWrongImageWithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5);
    
    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
    
    UIColor *selectColor = [UIColor orangeColor];
    
    [selectColor set];
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    
    [selectColor setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - getters

- (NSMutableArray *)selectPoints {
    if (!_selectPoints) {
        _selectPoints = [[NSMutableArray alloc] initWithCapacity:9];
    }
    return _selectPoints;
}

- (NSMutableArray *)points {
    if (!_points) {
        _points = [[NSMutableArray alloc] initWithCapacity:9];
    }
    return _points;
}

@end
