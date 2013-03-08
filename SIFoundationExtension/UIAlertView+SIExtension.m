//
//  UIAlertView+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 2/1/13.
//  Copyright (c) 2012-2013 Silicon Illusions, Inc. All rights reserved.
//

#import "UIAlertView+SIExtension.h"

static NSString *SI_ALERTVIEW_BUTTON_KEY = @"com.siliconillusions.alertview.button";

@implementation SIAlertViewButton

+ (id)alertViewButtonWithTitle:(NSString *)title andBlock:(void (^)(void))block
{
    SIAlertViewButton *alertViewButton = [[self alloc] init];
    [alertViewButton setTitle:title];
    [alertViewButton setBlock:block];
    return alertViewButton;
}

@end

#pragma mark

@implementation UIAlertView (SIExtension)

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
   cancelButtonItem:(SIAlertViewButton *)cancelButtonItem
   otherButtonItems:(SIAlertViewButton *)otherButtonItems, ...
{
    if( self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonItem.title otherButtonTitles:nil] )
    {
        NSMutableArray *buttonsArray = [NSMutableArray arrayWithCapacity:1];
        
        SIAlertViewButton *eachItem;
        va_list argumentList;
        if( otherButtonItems )
        {
            [buttonsArray addObject:otherButtonItems];
            va_start(argumentList, otherButtonItems);
            while( (eachItem = va_arg(argumentList, SIAlertViewButton *)))
                [buttonsArray addObject:eachItem];
            va_end(argumentList);
        }
        
        for( SIAlertViewButton *item in buttonsArray)
            [self addButtonWithTitle:item.title];

        if( cancelButtonItem )
            [buttonsArray insertObject:cancelButtonItem atIndex:0];

        objc_setAssociatedObject(self, (__bridge const void *)SI_ALERTVIEW_BUTTON_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setDelegate:self];
        
    }
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If the button index is -1 it means we were dismissed with no selection
    if( buttonIndex >= 0 )
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)SI_ALERTVIEW_BUTTON_KEY);
        SIAlertViewButton *item = [buttonsArray objectAtIndex:buttonIndex];
        if( item.block )
            item.block();
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)SI_ALERTVIEW_BUTTON_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
