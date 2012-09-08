//
//  SIPopupView.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIPopupView;

@protocol SIPopupViewDelegate <NSObject>

@optional
- (void)popupViewWillAppear:(SIPopupView *)popupView;
- (void)popupViewDidAppear:(SIPopupView *)popupView;
- (void)popupViewWillDisappear:(SIPopupView *)popupView;
- (void)popupViewDidDisappear:(SIPopupView *)popupView;

@end

@class SIPopupDisplayer;

@interface SIPopupView : UIView

@property (atomic, readwrite, assign) CGFloat arcRadius;
@property (nonatomic, readwrite, unsafe_unretained) id <SIPopupViewDelegate> delegate;
@property (nonatomic, readwrite, retain) UIColor *backgroundColor;
@property (nonatomic, readwrite, retain) SIPopupDisplayer *parentPopupDisplayer;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
