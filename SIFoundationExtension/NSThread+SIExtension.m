//
//  NSThread+SIExtension.m
//  Crunch
//
//  Created by Matias Pequeno on 9/9/12.
//  Copyright (c) 2012 AvatarLA. All rights reserved.
//

#import "NSThread+SIExtension.h"

// Default thread priority
static const dispatch_queue_priority_t kDefaultPriorityForNewThreads = DISPATCH_QUEUE_PRIORITY_HIGH;

// Thread naming
static int __threadId = 2; // 0 = invalid, 1 = main, +2 = non-main threads
static void __baptizeCurrentThread()
{
    NSThread *currentThread = [NSThread currentThread];
    if( ![currentThread name] || [currentThread.name isEmpty] )
        [currentThread setName:[NSString stringWithFormat:@"%03d", [currentThread isMainThread] ? 1 : __threadId++]];
    
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
            __baptizeCurrentThread();
            block();
            
        } else {
            
            if (waitUntilDone) {
                dispatch_sync(dispatch_get_main_queue(), ^ {
                    __baptizeCurrentThread();
                    block();
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    __baptizeCurrentThread();
                    block();
                });
            }
        }
        
    } else
        block();
}

@end
