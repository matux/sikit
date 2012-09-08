//
//  CATransition+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 8/19/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "CATransition+SIExtension.h"

@implementation CATransition (SIExtension)

+ (id)fadeTransitionWithDuration:(CFTimeInterval)interval
{
    CATransition *transition = [CATransition animation];
    [transition setDuration:interval];
    [transition setType:kCATransitionFade];
    [transition setRemovedOnCompletion:YES];

    return transition;
}

@end
