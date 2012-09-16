//
//  SIIndicatorPopupView.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIPopupView.h"

@interface SIIndicatorPopupView : SIPopupView
{
    UIActivityIndicatorView *_indicatorView;
    UILabel *_label;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *textFont;

+ (SIIndicatorPopupView *)loadingPopupWithFrame:(CGRect)frame andText:(NSString *)text;

@end
