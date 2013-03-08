//
//  SIPopupView.m
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIPopupView.h"
#import "UIColor+SIExtension.h"
#import "SIPopupDisplayer.h"

#define kDefaultPopupArcRadius      10.0f

@implementation SIPopupView

- (id)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [super setBackgroundColor:[UIColor clearColor]];
        
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        [self setArcRadius:kDefaultPopupArcRadius];
    }

    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    CGContextSetRGBFillColor(context, self.backgroundColor.red, self.backgroundColor.green, self.backgroundColor.blue, self.backgroundColor.alpha);
    CGContextMoveToPoint(context, CGRectGetMinX(self.bounds) + self.arcRadius, CGRectGetMinY(self.bounds));
    CGContextAddArc(context, CGRectGetMaxX(self.bounds) - self.arcRadius, CGRectGetMinY(self.bounds) + self.arcRadius, self.arcRadius, 3 * (float) M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(self.bounds) - self.arcRadius, CGRectGetMaxY(self.bounds) - self.arcRadius, self.arcRadius, 0, (float) M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(self.bounds) + self.arcRadius, CGRectGetMaxY(self.bounds) - self.arcRadius, self.arcRadius, (float) M_PI / 2, (float) M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(self.bounds) + self.arcRadius, CGRectGetMinY(self.bounds) + self.arcRadius, self.arcRadius, (float) M_PI, 3 * (float) M_PI / 2, 0);
    
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark
#pragma mark Show/Hide Animations

- (void)showAnimated:(BOOL)animated
{
    __block __weak SIPopupView * blockSelf = self;
    
    if( [_delegate respondsToSelector:@selector(popupViewWillAppear:)] ) {
        [_delegate popupViewWillAppear:self];
    }
    
    [self setAlpha:0];
    
    if( animated )
    {
        [UIView animateWithDuration:.3f animations:^{
            blockSelf.alpha = 1.f;
        } completion:^(BOOL finished) {
            if( [blockSelf.delegate respondsToSelector:@selector(popupViewDidAppear:)] ) {
                [blockSelf.delegate popupViewDidAppear:blockSelf];
            }
        }];
    }
    else
    {
        [self setAlpha:1.f];
        
        if( [_delegate respondsToSelector:@selector(popupViewDidAppear:)] ) {
            [_delegate popupViewDidAppear:self];
        }

    }
}

- (void)hideAnimated:(BOOL)animated
{
    __weak __block SIPopupView * blockSelf = self;
    
    if( [_delegate respondsToSelector:@selector(popupViewWillDisappear:)] ) {
        [_delegate popupViewWillDisappear:self];
    }

    if( animated )
    {
        
        [UIView animateWithDuration:.3f animations:^{
            blockSelf.alpha = 0.f;
        } completion:^(BOOL finished) {
            if( [blockSelf.delegate respondsToSelector:@selector(popupViewDidDisappear:)] ) {
                [blockSelf.delegate popupViewDidDisappear:blockSelf];
            }
        }];
        
    }
    else
    {
        [self setAlpha:0];

        if( [_delegate respondsToSelector:@selector(popupViewDidDisappear:)] ) {
            [_delegate popupViewDidDisappear:self];
        }

    }
}

@end
