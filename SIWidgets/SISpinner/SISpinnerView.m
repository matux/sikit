//
//  SISpinnerView.m
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SISpinnerView.h"

@interface SISpinnerView ()

@property (nonatomic, readwrite, retain) SISpinner *spinner;
@property (nonatomic, readwrite, retain) UIImageView *containerImageView;
@property (nonatomic, readwrite, retain) UIImageView *glowImageView;

@end

#pragma mark

@implementation SISpinnerView

@dynamic indefinite;

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    UIImage *containerImage = [UIImage imageNamed:@"containerImage"];
    UIImage *glowImage = [UIImage imageNamed:@"glow"];

    if( self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, glowImage.size.width, glowImage.size.height)] )
    {
        _containerImageView = [[UIImageView alloc] initWithImage:containerImage];
        _containerImageView.alpha = 0.8f;
        
        _glowImageView = [[UIImageView alloc] initWithImage:glowImage];
        _glowImageView.frame = CGRectMake(0,0, CGRectGetWidth(_glowImageView.frame), CGRectGetHeight(_glowImageView.frame));
        
        _spinner = [[SISpinner alloc] initWithFrame:CGRectMake(0.5f, 0.5f, CGRectGetWidth(_spinner.frame), CGRectGetHeight(_spinner.frame))];
        
        CGRect glowRect = _glowImageView.frame;
        CGRect containerRect = _containerImageView.frame;
        _containerImageView.frame = CGRectMake(CGRectGetWidth(glowRect)/2-CGRectGetWidth(containerRect)/2, CGRectGetHeight(glowRect)/2-CGRectGetHeight(containerRect)/2, CGRectGetWidth(containerRect), CGRectGetHeight(containerRect));
        
        [_containerImageView addSubview:_spinner];
        [self addSubview:_glowImageView];
        [self insertSubview:_containerImageView aboveSubview:_glowImageView];
    }
    
    return self;
    
}

- (void)dealloc
{
    [_spinner removeFromSuperview];
    [_spinner release];
    
    [_containerImageView removeFromSuperview];
    [_containerImageView release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Public methods

- (void)startIndefiniteMode
{
    [self stopIndefiniteMode];
    
    _spinner.progress = 99.9f;
    _glowImageView.alpha = 1.f;
    
    [_spinner startIndefiniteAnimation];
}

- (void)stopIndefiniteMode
{
    [_spinner stopIndefiniteAnimation];
    self.progress = 0.0;
}

#pragma mark -
#pragma mark Custom Getter and Setters

- (BOOL)indefinite
{
    return _spinner.indefiniteMode;
}

- (CGFloat)progress
{
    return _spinner.progress;
}

- (void)setProgress:(CGFloat)progress
{
    if( !self.indefinite )
    {
        _spinner.progress = progress;
        _glowImageView.alpha = progress / 100.f;
    }
}

@end
