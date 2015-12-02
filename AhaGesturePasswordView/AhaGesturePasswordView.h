//
//  AhaGesturePasswordView.h
//  AhaGesturePasswordDemo
//
//  Created by wei on 15/11/30.
//  Copyright © 2015年 livv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AhaGesturePasswordView;

@protocol AhaGesturePasswordDelegate <NSObject>

- (void)ahaGesturePasswordView:(AhaGesturePasswordView *)gestureView password:(NSString *)pwd;

@end


@interface AhaGesturePasswordView : UIView

@property (assign, nonatomic) id<AhaGesturePasswordDelegate> delegate;

@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign) CGFloat tintAlpha;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat circleLineWidth;
@property (nonatomic, assign) CGFloat smallCircleRatio;    //default 0.3, max 1.0


@property (nonatomic, strong) UIColor *normalTintColor;
@property (nonatomic, strong) UIColor *selectTintColor;
@property (nonatomic, strong) UIColor *errorTintColor;


- (void)reset;
- (void)setError;

@end
