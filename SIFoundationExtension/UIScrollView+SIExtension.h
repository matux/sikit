//
//  UIScrollView+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 8/25/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (SIExtension)

- (void)scrollToTopAnimated:(BOOL)animated;
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
