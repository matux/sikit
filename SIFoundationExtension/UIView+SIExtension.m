//
//  UIView+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "UIView+SIExtension.h"

@implementation UIView (SIExtension)

- (UIViewController *)firstAvailableViewController
{
    return (UIViewController *)[self traverseResponderChainForClass:[UIViewController class]];
}

- (id)traverseResponderChainForClass:(Class)Class
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[Class class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForClass:Class];
    } else {
        return nil;
    }
}

- (void)moveTo:(CGPoint)pos
{
	CGRect _frame = self.frame;
    _frame.origin = pos;
    self.frame = _frame;
}

- (void)moveBy:(CGPoint)pos
{
	CGRect _frame = self.frame;	
    _frame.origin.x += pos.x;
	_frame.origin.y += pos.y;
	self.frame = _frame;
}

- (void)resizeTo:(CGSize)size
{
	CGRect _frame = self.frame;
    _frame.size = size;
    self.frame = _frame;
	self.bounds = CGRectMake(0, 0, _frame.size.width, _frame.size.height);
}

- (void)resizeBy:(CGSize)size
{
	CGRect _frame = self.frame;	
    _frame.size.width += size.width;
	_frame.size.height += size.height;
	self.frame = _frame;
	self.bounds = CGRectMake(0, 0, _frame.size.width, _frame.size.height);
}

- (void)moveAndResizeBy:(CGRect)rect
{
	CGRect _frame = self.frame;	
    _frame.origin.x += rect.origin.x;
	_frame.origin.y += rect.origin.y;
    _frame.size.width += rect.size.width;
	_frame.size.height += rect.size.height;
	self.frame = _frame;
	self.bounds = CGRectMake(0, 0, _frame.size.width, _frame.size.height);
}

- (void)setFrameX:(CGFloat)x
{
    [self moveTo:CGPointMake(x, self.frame.origin.y)];
}

- (void)setFrameY:(CGFloat)y
{
    [self moveTo:CGPointMake(self.frame.origin.x, y)];
}

- (void)setFrameHeight:(CGFloat)height
{
    [self resizeTo:CGSizeMake(self.frame.size.width, height)];
}

- (void)setFrameWidth:(CGFloat)width
{
    [self resizeTo:CGSizeMake(width, self.frame.size.height)];
}

- (void)removeAllSubviews
{
    for( UIView *subview in self.subviews )
        [subview removeFromSuperview];
}

- (NSString *)frameDescriptionRecursive:(int)recursive
{
    NSMutableString *description = [NSMutableString stringWithCapacity:100];
    
    // Add some extra info if root
    if( recursive == 1 )
        [description appendFormat:@"-[UIView frameDescriptionRecursive:%@]\n", recursive?@"YES":@"NO"];
    
    // Write down frame info
    [description appendFormat:@"<frame = (% 4.0f % 4.0f; % 4.0f % 4.0f); ", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height];
    // Write down autoresizing info
    [description appendFormat:@"autoresizesSubviews = %@; ", self.autoresizesSubviews?@"YES":@"NO"];
    [description appendString:@"autoresizingMask = "];
    if( self.autoresizingMask )
    {
        if( self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin )    [description appendString:@"LM+"];
        if( self.autoresizingMask & UIViewAutoresizingFlexibleRightMargin )   [description appendString:@"RM+"];
        if( self.autoresizingMask & UIViewAutoresizingFlexibleTopMargin )     [description appendString:@"TM+"];
        if( self.autoresizingMask & UIViewAutoresizingFlexibleBottomMargin )  [description appendString:@"BM+"];
        if( self.autoresizingMask & UIViewAutoresizingFlexibleWidth )         [description appendString:@"W+"];
        if( self.autoresizingMask & UIViewAutoresizingFlexibleHeight )        [description appendString:@"H"];
        
        if( [description characterAtIndex:[description length] - 1] == '+' )
            [description deleteCharactersInRange:NSMakeRange([description length] - 1, 1)];
    }
    else
        [description appendString:@"None"];
    
    // Write down class name
    [description appendFormat:@"; %@", NSStringFromClass([self class])];
    // Show belonging UIViewController if possible
    if( [self respondsToSelector:@selector(firstAvailableUIViewController)] )
        [description appendFormat:@" in %@", NSStringFromClass([[self firstAvailableViewController] class])];
    [description appendString:@";>\n"];
    
    // If recursive, go nuts
    if( recursive /*&& [self.subviews count]*/ )
    {
        // Append subviews' frame info
        for( UIView *view in self.subviews ) {
            // Padding (format)
            for( int lvl = 0; lvl < recursive; ++lvl)
                [description appendString:@"|\t"];
            [description appendFormat:@"%@", [view frameDescriptionRecursive:recursive + 1]];
        }
    
    }
    
    return description;
    
}

@end
