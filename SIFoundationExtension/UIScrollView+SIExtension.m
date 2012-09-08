//
//  UIScrollView+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 8/25/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "UIScrollView+SIExtension.h"

@implementation UIScrollView (SIExtension)

- (void)scrollToTopAnimated:(BOOL)animated
{
    [self setContentOffset:CGPointZero animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    CGPoint bottomOffset = CGPointMake(0, self.contentSize.height - self.bounds.size.height);
    [self setContentOffset:bottomOffset animated:animated];
}

@end
