//
//  UISearchBar+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/6/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (SIExtension)

- (UIButton *)cancelButton;
- (void)setCancelButtonEnabled:(BOOL)yesOrNo;

@end
