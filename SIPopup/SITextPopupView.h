//
//  SITextPopupView.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIPopupView.h"

@interface SITextPopupView : SIPopupView

@property (nonatomic, readwrite, copy) NSString *text;
@property (nonatomic, readwrite, retain) UIColor *textColor;
@property (nonatomic, readwrite, retain) UIFont *textFont;

+ (SITextPopupView *)errorPopupWithFrame:(CGRect)frame andText:(NSString *)text;
+ (SITextPopupView *)normalPopupWithFrame:(CGRect)frame andText:(NSString *)text;

@end
