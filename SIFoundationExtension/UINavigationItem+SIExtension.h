//
//  UINavigationItem+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 8/19/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (SIExtension)

- (void)setBackBarButtonItem:(UIBarButtonItem *)backBarButtonItem targetNavigationController:(UINavigationController *)navigationController;

@end
