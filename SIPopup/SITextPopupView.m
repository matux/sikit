//
//  SITextPopupView.m
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SITextPopupView.h"
#import "UIColor+SIExtension.h"

#define kLabelDefaultFont       [UIFont boldSystemFontOfSize:12.0f];

@interface SITextPopupView ()
{
    UILabel *_label;
}

@end

#pragma mark -

@implementation SITextPopupView

- (id)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.font = kLabelDefaultFont;
    }

    return self;
}

- (void)dealloc
{
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
    _label.adjustsFontSizeToFitWidth = NO;
    _label.textAlignment = UITextAlignmentCenter;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.lineBreakMode = UILineBreakModeTailTruncation;
    _label.numberOfLines = 0;

    [self addSubview:_label];
}

+ (SITextPopupView *)errorPopupWithFrame:(CGRect)frame andText:(NSString *)text
{
    SITextPopupView *alertView = [[[SITextPopupView alloc] initWithFrame:frame] autorelease];
    alertView.textColor = [UIColor whiteColor];
    alertView.backgroundColor = [UIColor colorWithHex:0xDC3232 alpha:.85f];
    alertView.text = text;
    return alertView;
}

+ (SITextPopupView *)normalPopupWithFrame:(CGRect)frame andText:(NSString *)text
{
    SITextPopupView *alertView = [[[SITextPopupView alloc] initWithFrame:frame] autorelease];
    alertView.textColor = [UIColor whiteColor];
    alertView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:.85f];
    alertView.text = text;
    return alertView;
}

@end
