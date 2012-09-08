//
//  UINavigationItem+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 8/19/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "UINavigationItem+SIExtension.h"
#import "Availability.h"

@implementation UINavigationItem (SIExtension)

- (void)setBackBarButtonItem:(UIBarButtonItem *)backBarButtonItem targetNavigationController:(UINavigationController *)navigationController
{
    // Indicate that the left item replaces the back button
    if ([self respondsToSelector:@selector(setLeftItemsSupplementBackButton:)]) {
         [self setLeftItemsSupplementBackButton:NO];
    } else {
        [self setHidesBackButton:YES];
    }
    
    // Set the new back button
    [self setLeftBarButtonItem:backBarButtonItem];
    
    // Auto-configure back action
    if( [backBarButtonItem.customView isKindOfClass:[UIButton class]] )
    {
        UIButton *backButton = (UIButton *)backBarButtonItem.customView;
        [backButton addTarget:navigationController
                       action:@selector(popViewControllerAnimated:)
             forControlEvents:UIControlEventTouchUpInside];
    }

}

@end
