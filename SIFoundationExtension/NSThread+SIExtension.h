//
//  NSThread+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

@interface NSThread (SIExtension)

+ (void)dispatchInNewThread:(void (^)(void))block;
+ (void)dispatchInNewThread:(void (^)(void))block withQueuePriority:(dispatch_queue_priority_t)priority;
+ (void)dispatchInNewThread:(void (^)(void))block withQueuePriority:(dispatch_queue_priority_t)queuePriority sync:(BOOL)sync;

+ (void)dispatchInMainThread:(void (^)(void))block;
+ (void)dispatchInMainThread:(void (^)(void))block sync:(BOOL)yesOrNo;
+ (void)dispatchInMainThread:(void (^)(void))block afterDelay:(CGFloat)delay;

@end
