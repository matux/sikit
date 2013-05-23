//
//  SITooltip.m
//  SIKit
//
//  Created by Matias Pequeno on 5/14/13.
//  Copyright (c) 2013 Silicon Illusions, Inc. All rights reserved.
//

#import "SITooltip.h"

static CGFloat __defaultFontSize = 16.f;
static CGFloat __fadeDuration = .25f;

@implementation SITooltip
{
    UIImageView *_close;
    UIImageView *_background;
    UIImageView *_arrow;
    UILabel *_label;
    UIButton *_overlay;
}

+ (id)showTooltipWithText:(NSString *)text view:(UIView *)view rect:(UIView *)targetView arrowDirection:(TooltipArrowDirection)direction delegate:(id<SITooltipDelegate>)delegate
{
    return [self showTooltipWithText:text view:view rect:targetView offset:CGPointZero arrowDirection:direction delegate:delegate];
}

+ (id)showTooltipWithText:(NSString *)text view:(UIView *)view rect:(UIView *)targetView offset:(CGPoint)offset arrowDirection:(TooltipArrowDirection)direction delegate:(id<SITooltipDelegate>)delegate
{
    LogDebug(@"Showing tooltip with text %@", text);
    
    SITooltip *tooltip = [[SITooltip alloc] initWithArrowDirection:direction andText:text];
    
    [tooltip setDelegate:delegate];
    
    CGRect frame;
    frame.size = tooltip.frame.size;
    
    CGRect tooltipRect = view.superview == targetView ? targetView.frame : [targetView.superview convertRect:targetView.frame toView:view];
    tooltipRect.origin.x += offset.x;
    tooltipRect.origin.y += offset.y;
    
    switch (direction) {
        case kTooltipArrowDirectionUp:
            frame.origin = CGPointMake((tooltipRect.origin.x + tooltipRect.size.width * 0.5) - tooltip.frame.size.width * 0.5, tooltipRect.origin.y + tooltipRect.size.height);
            break;
        case kTooltipArrowDirectionDown:
            frame.origin = CGPointMake((tooltipRect.origin.x + tooltipRect.size.width * 0.5) - tooltip.frame.size.width * 0.5, tooltipRect.origin.y - tooltip.frame.size.height);
            break;
        default:
            frame.origin = CGPointZero;
            break;
    }
    
    tooltip.frame = CGRectIntegral(frame);
    tooltip.alpha = 0.f;
    
    [view addSubview:tooltip];
    
    UIView *rootView = [[[UIApplication sharedApplication] keyWindow] subviews][0];
    CGRect absRect = [view convertRect:tooltip.frame toView:rootView];
    CGFloat maxWidth = SIIdiomIsPhone() ? 320.f : SICurrentOrientationIsLandscape() ? 1024 : 768;
    
    frame = tooltip.frame;
    
    if (absRect.origin.x + absRect.size.width > maxWidth) {
        frame.origin.x -= (((absRect.origin.x + absRect.size.width) - maxWidth));
    }
    
    if (absRect.origin.x < 0) {
        frame.origin.x += fabsf(absRect.origin.x);
    }
    
    tooltip.frame = frame;
    
    [tooltip adjustArrowToView:targetView];
    
    [UIView animateWithDuration:__fadeDuration animations:^{
        tooltip.alpha = 1.f;
    }];
    
    return tooltip;
}

+ (void)setFadeDuration:(CGFloat)duration
{
    __fadeDuration = duration;
}

- (id)initWithArrowDirection:(TooltipArrowDirection)direction andText:(NSString *)text
{
    if (self = [super initWithFrame:CGRectZero]) {
        
        CGFloat alphaValue = 0.9;
        
        CGFloat textHeight = [text sizeWithFont:[UIFont systemFontOfSize:__defaultFontSize] constrainedToSize:CGSizeMake(245, 999)].height;
        
        NSString *imageName;
        CGRect labelRect;
        CGPoint arrowOrigin;
        CGFloat bgOffset;
        
        switch (direction) {
            case kTooltipArrowDirectionUp:
                imageName = @"tooltip_up.png";
                arrowOrigin = CGPointMake(30, 0);
                labelRect.origin = CGPointMake(15, 21);
                bgOffset = 12.5f;
                break;
                
            case kTooltipArrowDirectionDown:
                imageName = @"tooltip_down.png";
                labelRect.origin = CGPointMake(15, 9);
                arrowOrigin = CGPointMake(30, textHeight + 14);
                bgOffset = 0.f;
                break;
                
            default:
                imageName = nil;
                labelRect.origin = CGPointZero;
                arrowOrigin = CGPointZero;
                bgOffset = 0.f;
                break;
        }
        
        labelRect.size = CGSizeMake(245, textHeight);
        
        UIImage *bgImage = [[UIImage imageNamed:@"tooltip_body.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:7];
        
        _background = [[UIImageView alloc] initWithImage:bgImage];
        [_background setAlpha:alphaValue];
        [_background setFrame:CGRectMake(0, bgOffset, 300, textHeight + 24)];
        
        [self addSubview:_background];

        _arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [_arrow setFrame:CGRectMake(arrowOrigin.x, arrowOrigin.y, _arrow.frame.size.width, _arrow.frame.size.height)];
        [_arrow setAlpha:alphaValue];
        [self addSubview:_arrow];
        
        _label = [[UILabel alloc] initWithFrame:labelRect];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setNumberOfLines:0];
        [_label setFont:[UIFont systemFontOfSize:__defaultFontSize]];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setShadowColor:[UIColor darkGrayColor]];
        [_label setShadowOffset:CGSizeMake(0, -1)];
        [_label setTextAlignment:UITextAlignmentCenter];
        [_label setAdjustsFontSizeToFitWidth:YES];
        [_label setText:text];
        
        UIImage *closeImage = [UIImage imageNamed:@"icon_circle_x.png"];
        
        _close = [[UIImageView alloc] initWithImage:closeImage];
        [_close setCenter:CGPointMake(_background.frame.size.width - 24, _label.center.y)];
        [self addSubview:_close];
        
        [self addSubview:_label];
        
        CGRect bounds = _background.bounds;
        
        if (direction == kTooltipArrowDirectionUp)
            bounds.size.height += _background.frame.origin.y;
        else
            bounds.size.height = _arrow.frame.origin.y + _arrow.frame.size.height;
        
        self.bounds = bounds;
        
        _overlay = [UIButton buttonWithType:UIButtonTypeCustom];
        [_overlay setFrame:bounds];
        
        [_overlay addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_overlay];
    }
    
    return self;
}

- (void)adjustArrowToView:(UIView *)view
{
    CGRect targetRect = view.frame;
    CGFloat point = CGRectGetMidX(targetRect);
    point = [[view superview] convertPoint:CGPointMake(point, 0) toView:self].x;
    
    CGRect f = _arrow.frame;
    f.origin.x = point - f.size.width * 0.5;
    _arrow.frame = f;
    
}

- (void)buttonTapped
{
    __weak __block SITooltip *blockSelf = self;
    
    [UIView animateWithDuration:__fadeDuration animations:^{
        blockSelf.alpha = 0.f;
    } completion:^(BOOL finished) {
        [blockSelf removeFromSuperview];
        if ([_delegate respondsToSelector:@selector(tooltipTapped:)])
            [_delegate tooltipTapped:blockSelf];
    }];
}

- (void)dismiss
{
    [self buttonTapped];
}

@end
