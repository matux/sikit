//
//  UIView+SIPopup.m
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "UIView+SIPopup.h"
#import "SIPopupDisplayer.h"
#import "SITextPopupView.h"
#import "SIIndicatorPopupView.h"

static char const * const kPopupDisplayerKey = "PopupDisplayerKey";

#pragma mark -

@implementation UIView (SIPopup)

@dynamic popupDisplayer;

- (void)showPopupWithText:(NSString *)text andDuration:(NSInteger)seconds andStyle:(SIPopupStyle)style
{
    if( [self popupDisplayer] )
        [NSException raise:@"SIPopupIsVisibleException" format:@"- [UIView showPopupWithText:andDuration:andStyle:] reached while popup is still visible."];
    
    SIPopupView *popupView = nil;
    switch( style ) {
        case SIPopupStyleNormal:
            popupView = [SITextPopupView normalPopupWithFrame:CGRectMake(0, 0, 200, 60) andText:text];
            break;
        case SIPopupStyleLoading:
            popupView = [SIIndicatorPopupView loadingPopupWithFrame:CGRectMake(0, 0, 150, 150) andText:text];
            break;
        case SIPopupStyleError: {
            CGFloat popupWidth = 150.f;
            CGFloat popupHeight = 150.f;
            CGFloat popupVerticalMargin = popupHeight / 7.f;
            if (self.frame.size.height <= popupHeight + popupVerticalMargin)
                popupHeight = self.frame.size.height - (popupVerticalMargin * 3);
            
            popupView = [SITextPopupView errorPopupWithFrame:CGRectMake(0, 0, popupWidth, popupHeight) andText:text];
            [(SITextPopupView *)popupView setTextFont:[UIFont boldSystemFontOfSize:18.0f]];
        } break;
        default:
            break;
    }
    
    [popupView setDelegate:self];
    [popupView setCenter:SICenterPointForView(self)];
    
    // Popup Displayer    
    [self setPopupDisplayer:[[[SIPopupDisplayer alloc] initWithPopupView:popupView] autorelease]];
    [[self popupDisplayer] displayInView:self during:seconds isModal:NO];
    
    //});
}

- (void)hidePopup
{
    [[self popupDisplayer] hide];
}

#pragma mark -
#pragma mark SIPopupViewDelegate implementation

- (void)popupViewDidDisappear:(SIPopupView *)popupView
{
    //objc_removeAssociatedObjects([self popupDisplayer]);
    [self setPopupDisplayer:nil];
}

#pragma mark -
#pragma mark SIPopupDisplayer associative reference

- (SIPopupDisplayer *)popupDisplayer
{
    return objc_getAssociatedObject(self, kPopupDisplayerKey);
}

- (void)setPopupDisplayer:(SIPopupDisplayer *)popupDisplayer
{
    objc_setAssociatedObject(self, kPopupDisplayerKey, popupDisplayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
