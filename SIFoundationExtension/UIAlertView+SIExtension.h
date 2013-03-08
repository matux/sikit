//
//  UIAlertView+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 2/1/13.
//  Copyright (c) 2013 WHI Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIAlertViewButton : NSObject

@property (retain, nonatomic) NSString *title;
@property (copy, nonatomic) void (^block)();

+ (id)alertViewButtonWithTitle:(NSString *)title andBlock:(void (^)(void))block;

@end

#pragma mark

@interface UIAlertView (SIExtension)

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonItem:(SIAlertViewButton *)cancelButtonItem otherButtonItems:(SIAlertViewButton *)inOtherButtonItems, ... NS_REQUIRES_NIL_TERMINATION;

@end
