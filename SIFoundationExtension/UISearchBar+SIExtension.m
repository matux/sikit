//
//  UISearchBar+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/6/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "UISearchBar+SIExtension.h"

@implementation UISearchBar (SIExtension)

- (UIButton *)cancelButton
{
    for (UIView *view in self.subviews)
        if ([view isKindOfClass:[UIButton class]])
            return (UIButton *)view;
    
    return nil;
    
}

- (void)setCancelButtonEnabled:(BOOL)yesOrNo
{
    [self cancelButton].enabled = yesOrNo;
}

@end
