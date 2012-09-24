//
//  SIIndicatorPopupView.m
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIIndicatorPopupView.h"
#import "UIColor+SIExtension.h"
#import "SIUtil.h"

#define kLabelDefaultFont   [UIFont boldSystemFontOfSize:18.0f];
#define kLabelMargin        20.0f

@implementation SIIndicatorPopupView

- (id)initWithFrame:(CGRect)frame 
{
    if( self = [super initWithFrame:frame] )
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

        _label = [[UILabel alloc] init];
        _label.font = kLabelDefaultFont;
    }

    return self;
}

- (void)dealloc 
{
    [_indicatorView release];
    [_label release];

    [super dealloc];
}

- (void)setText:(NSString *)value 
{
    _label.text = value;
}

- (NSString *)text 
{
    return _label.text;
}

- (void)setTextFont:(UIFont *)value 
{
    _label.font = value;
}

- (UIFont *)textFont 
{
    return _label.font;
}

- (void)setTextColor:(UIColor *)value 
{
    _label.textColor = value;
}

- (UIColor *)textColor 
{
    return _label.textColor;
}

- (void)layoutSubviews 
{
    _indicatorView.frame = CGRectMake(self.frame.size.width/2 - _indicatorView.frame.size.width/2, 0, _indicatorView.frame.size.width, _indicatorView.frame.size.height);
    [_indicatorView startAnimating];

    CGFloat indicatorViewBottom = _indicatorView.frame.origin.y + _indicatorView.frame.size.height;

    CGSize labelSize = [_label.text sizeWithFont:_label.font];
    _label.frame = CGRectMake(0, indicatorViewBottom + kLabelMargin, self.frame.size.width, labelSize.height);
    _label.adjustsFontSizeToFitWidth = NO;
    _label.textAlignment = UITextAlignmentCenter;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.lineBreakMode = UILineBreakModeWordWrap;
    _label.numberOfLines = 0;
    
    CGFloat wrapperViewHeight = _label.frame.origin.y + _label.frame.size.height;
    UIView *wrapperView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, wrapperViewHeight)] autorelease];
    wrapperView.center = SICenterPointForView(self);

    [wrapperView addSubview:_indicatorView];
    [wrapperView addSubview:_label];

    [self addSubview:wrapperView];
}

+ (SIIndicatorPopupView *)loadingPopupWithFrame:(CGRect)frame andText:(NSString *)text
{
    SIIndicatorPopupView *indicatorPopupView = [[[SIIndicatorPopupView alloc] initWithFrame:frame] autorelease];
    indicatorPopupView.textColor = [UIColor whiteColor];
    indicatorPopupView.backgroundColor = [UIColor colorWithHex:0x00000 alpha:0.85f];
    indicatorPopupView.text = text;
    return indicatorPopupView;
}

@end
