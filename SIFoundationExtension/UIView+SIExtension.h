//
//  UIView+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

@interface UIView (SIExtension)

- (UIViewController *)firstAvailableViewController;
- (id)traverseResponderChainForClass:(Class)c;
- (id)traverseSubviewsForClass:(Class)c;

- (void)moveTo:(CGPoint)pos;
- (void)moveBy:(CGPoint)pos;
- (void)resizeTo:(CGSize)size;
- (void)resizeBy:(CGSize)size;
- (void)moveAndResizeBy:(CGRect)rect;

- (void)setFrameX:(CGFloat)x;
- (void)setFrameY:(CGFloat)y;
- (void)setFrameHeight:(CGFloat)height;
- (void)setFrameWidth:(CGFloat)width;

- (void)removeAllSubviews;

- (NSString *)frameDescriptionRecursive:(int)recursive;

@end
