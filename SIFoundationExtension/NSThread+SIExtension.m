//
//  NSThread+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "NSThread+SIExtension.h"

// Default thread priority
static const dispatch_queue_priority_t kDefaultPriorityForNewThreads = DISPATCH_QUEUE_PRIORITY_HIGH;

// Thread naming
static void __baptizeCurrentThread()
{
    static int __threadId = 2; // 0 = invalid, 1 = main, +2 = non-main threads
    static NSString *bundleIdentifier = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    });
    
    NSThread *currentThread = [NSThread currentThread];
    if( ![currentThread name] || [currentThread.name isEmpty] )
        [currentThread setName:[NSString stringWithFormat:@"%@ (%03d)", bundleIdentifier, [currentThread isMainThread] ? 1 : __threadId++]];
    
    return;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation NSThread (SIExtension)

#pragma clang diagnostic pop

+ (void)executeInNewThread:(void (^)(void))block
{
    [NSThread executeInNewThread:block withQueuePriority:kDefaultPriorityForNewThreads];
}

+ (void)executeInNewThread:(void (^)(void))block withQueuePriority:(dispatch_queue_priority_t)queuePriority
{
    //[self performSelectorOnMainThread:(SEL)aSelector withObject:nil waitUntilDone:NO]
    //[NSThread detachNewThreadSelector: toTarget: withObject:]
    
    if( SI_GCD_AVAILABLE ) {
        
        dispatch_async(dispatch_get_global_queue(queuePriority, 0), ^ {
            __baptizeCurrentThread();
            block();
        });
        
    } else
        block();
    
}

+ (void)executeInMainThread:(void (^)(void))block
{
    [self executeInMainThread:block waitUntilDone:YES];
}

+ (void)executeInMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone
{
    if( SI_GCD_AVAILABLE ) {
        
        if ([self isMainThread]) {
            //__baptizeCurrentThread();
            block();
            
        } else {
            
            if (waitUntilDone) {
                dispatch_sync(dispatch_get_main_queue(), ^ {
                    //__baptizeCurrentThread();
                    block();
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    //__baptizeCurrentThread();
                    block();
                });
            }
        }
        
    } else
        block();
}

+ (void)executeInMainThread:(void (^)(void))block afterDelay:(CGFloat)delay
{
    int64_t internalDelay = delay * NSEC_PER_SEC;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, internalDelay);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
