//
//  SITooltip.h
//  SIKit
//
//  Created by Matias Pequeno on 5/14/13.
//  Copyright (c) 2013 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kTooltipArrowDirectionUndefined,
    kTooltipArrowDirectionUp,
    kTooltipArrowDirectionDown,
    kTooltipArrowDirectionCount
} TooltipArrowDirection;

@class SITooltip;

@protocol SITooltipDelegate <NSObject>

- (void)tooltipTapped:(SITooltip *)tooltip;

@end

#pragma mark -

@interface SITooltip : UIView

@property (nonatomic, weak) id<SITooltipDelegate> delegate;

+ (id)showTooltipWithText:(NSString *)text view:(UIView *)view rect:(UIView *)targetView arrowDirection:(TooltipArrowDirection)direction delegate:(id<SITooltipDelegate>)delegate;
+ (id)showTooltipWithText:(NSString *)text view:(UIView *)view rect:(UIView *)targetView offset:(CGPoint)offset arrowDirection:(TooltipArrowDirection)direction delegate:(id<SITooltipDelegate>)delegate;

- (void)dismiss;

@end
