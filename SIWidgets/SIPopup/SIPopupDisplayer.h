//
//  SIPopupDisplayer.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIPopupView;

@interface SIPopupDisplayer : NSObject
{
    SIPopupView *_popupView;
    UIView *_backgroundView;
}

@property (nonatomic, readonly, strong) SIPopupView *popupView;

- (id)initWithPopupView:(SIPopupView *)popupView;

- (void)hide;

- (void)displayInView:(UIView *)otherView isModal:(BOOL)isModal;
- (void)displayInView:(UIView *)otherView during:(NSInteger)duration isModal:(BOOL)isModal;
- (void)displayInView:(UIView *)otherView whileBlock:(void(^)(void))block;

@end
