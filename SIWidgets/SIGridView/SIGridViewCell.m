//
//  SIGridViewCell.m
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIGridViewCell.h"

@interface SIGridViewCell ()

@property (nonatomic, readwrite, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, readwrite, retain) IBOutlet UIImageView *imageView;

@end

#pragma mark

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
    [_imageView setImageWithURL:[NSURL URLWithString:self.imageURL]];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_imageView setClipsToBounds:YES];
    
    _titleLabel.text = self.text;
    
    // calculate title label height depending on the text amount and font size
    CGSize maximumLabelSize;
        
    // if the mode is vertical, place the title label below the image, otherwise place it next to the image
    if( self.horizontalModeEnabled )
    {
        if (!self.imageWidth)
            self.imageWidth = _imageView.frame.size.width;
        
        maximumLabelSize = CGSizeMake(200, _titleLabel.frame.size.height);
        
        CGSize expectedLabelSize = [self.text sizeWithFont:_titleLabel.font
                                         constrainedToSize:maximumLabelSize 
                                             lineBreakMode:_titleLabel.lineBreakMode];
        
        [_imageView setFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, self.imageWidth, _imageView.frame.size.height)];
        [_titleLabel setFrame:CGRectMake(5 + _imageView.frame.origin.x + _imageView.frame.size.width, _titleLabel.frame.origin.y, expectedLabelSize.width, _titleLabel.frame.size.height)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, _titleLabel.frame.origin.x + _titleLabel.frame.size.width + 15, self.frame.size.height)];
    }
    else
    {
        if (!self.imageHeight)
            self.imageHeight = _imageView.frame.size.height;
        
        maximumLabelSize = CGSizeMake(_titleLabel.frame.size.width, 1000);
        
        CGSize expectedLabelSize = [self.text sizeWithFont:_titleLabel.font 
                                         constrainedToSize:maximumLabelSize 
                                             lineBreakMode:_titleLabel.lineBreakMode]; 
        
        [_imageView setFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _imageView.frame.size.width, self.imageHeight)];
        [_titleLabel setFrame:CGRectMake(_titleLabel.frame.origin.x, 5 + _imageView.frame.origin.y + _imageView.frame.size.height, _titleLabel.frame.size.width, expectedLabelSize.height)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 15)];
    }
    
}

@end
