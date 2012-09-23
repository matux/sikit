//
//  SIGridViewCell.m
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIGridViewCell.h"

@implementation SIGridViewCell

- (void)dealloc
{
    [_titleLabel release];
    [_imageView release];
    
    [_text release];
    [_imageURL release];
    
    [super dealloc];
}

- (void)updateCellInfo:(NSDictionary *)data
{    
    [_imageView setImageWithURL:[NSURL URLWithString:_imageURL]];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setClipsToBounds:YES];
    
    _titleLabel.text = _text;
    
    // calculate title label height depending on the text amount and font size
    CGSize maximumLabelSize;
        
    // if the mode is vertical, place the title label below the image, otherwise place it next to the image
    if( _horizontalModeEnabled )
    {
        if( !_imageWidth )
            _imageWidth = _imageView.frame.size.width;
        
        maximumLabelSize = CGSizeMake(200.f, _titleLabel.frame.size.height);
        
        CGSize expectedLabelSize = [_text sizeWithFont:_titleLabel.font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:_titleLabel.lineBreakMode];
        
        [_imageView setFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, self.imageWidth, _imageView.frame.size.height)];
        [_titleLabel setFrame:CGRectMake(5.f + _imageView.frame.origin.x + _imageView.frame.size.width, _titleLabel.frame.origin.y, expectedLabelSize.width, _titleLabel.frame.size.height)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, _titleLabel.frame.origin.x + _titleLabel.frame.size.width + 15.f, self.frame.size.height)];
    }
    else
    {
        if( !_imageHeight )
            _imageHeight = _imageView.frame.size.height;
        
        maximumLabelSize = CGSizeMake(_titleLabel.frame.size.width, 1000.f);
        
        CGSize expectedLabelSize = [_text sizeWithFont:_titleLabel.font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:_titleLabel.lineBreakMode];
        
        [_imageView setFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _imageView.frame.size.width, self.imageHeight)];
        [_titleLabel setFrame:CGRectMake(_titleLabel.frame.origin.x, 5.f + _imageView.frame.origin.y + _imageView.frame.size.height, _titleLabel.frame.size.width, expectedLabelSize.height)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + (_imageView.frame.origin.y * 2))];
    }
    
}

@end
