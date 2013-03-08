//
//  SIRateView.m
//  Crunch
//
//  Created by Matias Pequeno on 9/24/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIRateView.h"

@implementation SIRateView

- (void)initialize
{
    _editable = NO;
    _imageViews = [[NSMutableArray alloc] init];
    
    _maxRating = 5;
    _midMargin = 5;
    _minImageSize = CGSizeMake(5.f, 5.f);
}

- (id)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [self initialize];
    }
    
    return self;
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if( self = [super initWithCoder:decoder] )
    {
        [self initialize];
    }
    
    return self;
}

- (void)refresh
{
    for( int i = 0; i < _imageViews.count; i++ )
    {
        UIImageView *imageView = (UIImageView *)_imageViews[i];
        if( _rating >= i + 1 )
            imageView.image = _fullSelectedImage;
        else if( _rating > i )
            imageView.image = _halfSelectedImage;
        else
            imageView.image = _notSelectedImage;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if( !_notSelectedImage )
        return;
    
    float desiredImageWidth = (self.frame.size.width - (_leftMargin * 2) - (_midMargin * _imageViews.count)) / _imageViews.count;
    float imageWidth = MAX(_minImageSize.width, desiredImageWidth);
    float imageHeight = MAX(_minImageSize.height, self.frame.size.height);
    
    for( int i = 0; i < _imageViews.count; i++ )
    {
        UIImageView *imageView = (UIImageView *)_imageViews[i];
        imageView.frame = CGRectMake(_leftMargin + i * (_midMargin + imageWidth), 0, imageWidth, imageHeight);
    }
    
}

#pragma mark
#pragma mark Handle touch

- (void)handleTouchAtLocation:(CGPoint)touchLocation
{
    if( !_editable )
        return;
    
    int newRating = 0;
    for( int i = _imageViews.count - 1; i >= 0 && !newRating; i-- )
    {
        UIImageView *imageView = (UIImageView *)_imageViews[i];
        if( touchLocation.x > imageView.frame.origin.x )
            newRating = i + 1;
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( [_delegate respondsToSelector:@selector(rateView:ratingDidChange:)] )
        [_delegate rateView:self ratingDidChange:_rating];
}

#pragma mark
#pragma mark Custom Getters and Setters

- (void)setMaxRating:(int)maxRating
{
    _maxRating = maxRating;
    
    // Remove old image views
    for( int i = 0; i < _imageViews.count; i++ )
    {
        UIImageView *imageView = (UIImageView *)_imageViews[i];
        [imageView removeFromSuperview];
    }
    
    [_imageViews removeAllObjects];
    
    // Add new image views
    for( int i = 0; i < maxRating; i++ )
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeTopLeft; //UIViewContentModeScaleAspectFit;
        [_imageViews addObject:imageView];
        [self addSubview:imageView];
    }
    
    // Relayout and refresh
    [self setNeedsLayout];
    [self refresh];
    
}

- (void)setNotSelectedImage:(UIImage *)image
{
    _notSelectedImage = image; // retain];
    [self refresh];
}

- (void)setHalfSelectedImage:(UIImage *)image
{
    _halfSelectedImage = image; // retain];
    [self refresh];
}

- (void)setFullSelectedImage:(UIImage *)image
{
    _fullSelectedImage = image; // retain];
    [self refresh];
}

- (void)setRating:(float)rating
{
    _rating = rating;
    [self refresh];
}

@end
