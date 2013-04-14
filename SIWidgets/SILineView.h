//
//  SILineView.h
//  CanvassMate
//
//  Created by Matias Pequeno on 4/14/13.
//  Copyright (c) 2013 CanvassMate LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SILineView : UIView

@property (nonatomic, readwrite, copy) UIColor *lineColor;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;
@property (nonatomic, readwrite, assign) CGPoint from;
@property (nonatomic, readwrite, assign) CGPoint to;

+ (id)lineViewWithFrame:(CGRect)frame width:(CGFloat)width color:(UIColor *)color from:(CGPoint)from to:(CGPoint)to;

@end
