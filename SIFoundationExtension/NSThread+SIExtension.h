//
//  NSThread+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

@interface NSThread (SIExtension)

+ (void)executeInNewThread:(void (^)(void))block;
+ (void)executeInNewThread:(void (^)(void))block withQueuePriority:(dispatch_queue_priority_t)priority;

+ (void)executeInMainThread:(void (^)(void))block;
+ (void)executeInMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone;
+ (void)executeInMainThread:(void (^)(void))block afterDelay:(CGFloat)delay;

@end
