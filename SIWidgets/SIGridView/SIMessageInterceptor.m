//
//  SIMessageInterceptor.h
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIMessageInterceptor.h"

@implementation SIMessageInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([_middleMan respondsToSelector:aSelector])
        return _middleMan;
    
    if ([_receiver respondsToSelector:aSelector])
        return _receiver;
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([_middleMan respondsToSelector:aSelector])
        return YES;
    
    if ([_receiver respondsToSelector:aSelector])
        return YES;
    
    return [super respondsToSelector:aSelector];
}

@end
