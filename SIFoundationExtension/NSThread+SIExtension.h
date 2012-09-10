//
//  NSThread+SIExtension.h
//  Crunch
//
//  Created by Matias Pequeno on 9/9/12.
//  Copyright (c) 2012 AvatarLA. All rights reserved.
//

@interface NSThread (SIExtension)

+ (void)executeInNewThread:(void (^)(void))block;
+ (void)executeInNewThread:(void (^)(void))block withQueuePriority:(dispatch_queue_priority_t)priority;

+ (void)executeInMainThread:(void (^)(void))block;
+ (void)executeInMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone;

@end
