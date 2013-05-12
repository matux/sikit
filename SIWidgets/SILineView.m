//
//  SILineView.m
//  CanvassMate
//
//  Created by Matias Pequeno on 4/14/13.
//  Copyright (c) 2013 CanvassMate LLC. All rights reserved.
//

#import "SILineView.h"

@implementation SILineView

+ (id)lineViewWithFrame:(CGRect)frame width:(CGFloat)width color:(UIColor *)color from:(CGPoint)from to:(CGPoint)to
{
    SILineView *lineView = [[SILineView alloc] initWithFrame:frame];
    lineView.from = from;
    lineView.to = to;
    lineView.lineWidth = width;
    lineView.lineColor = color;
    return lineView;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _lineColor = [UIColor blackColor];
        _lineWidth = 1.f;
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark -

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Configure stroke
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    
    // Draw line
    CGContextMoveToPoint(context, _from.x, _from.y);
    CGContextAddLineToPoint(context, _to.x, _to.y);
    
    CGContextStrokePath(context);
}


@end
