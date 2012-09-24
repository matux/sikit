//
//  UIView+SIPopup.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIPopupView.h"
#import "SIPopupDisplayer.h"

typedef enum {
    SIPopupStyleNormal = 0,
    SIPopupStyleLoading,
    SIPopupStyleError
} SIPopupStyle;

#define NSIntegerForever    NSIntegerMax

@class SIPopupDisplayer;

@interface UIView (SIPopup) <SIPopupViewDelegate>

@property (nonatomic, readwrite, retain) SIPopupDisplayer *popupDisplayer;

- (void)showPopupWithText:(NSString *)text andDuration:(NSInteger)seconds andStyle:(SIPopupStyle)style;
- (void)hidePopup;

@end
