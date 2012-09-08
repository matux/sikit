//
//  UIView+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#pragma once

@interface UIView (SIExtension)

- (UIViewController *)firstAvailableViewController;
- (id)traverseResponderChainForClass:(Class)c;

- (void)moveTo:(CGPoint)pos;
- (void)moveBy:(CGPoint)pos;
- (void)resizeTo:(CGSize)size;
- (void)resizeBy:(CGSize)size;
- (void)moveAndResizeBy:(CGRect)rect;

- (void)removeAllSubviews;

- (NSString *)frameDescriptionRecursive:(int)recursive;

@end
