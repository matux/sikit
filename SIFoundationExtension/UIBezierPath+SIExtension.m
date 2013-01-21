//
//  UIBezierPath+SIExtension.m
//  Crunch
//
//  Created by Matias Pequeno on 9/24/12.
//  Copyright (c) 2012 AvatarLA. All rights reserved.
//

#import "UIBezierPath+SIExtension.h"

static const CGFloat offset = 10.f;
static const CGFloat curve = 5.f;

@implementation UIBezierPath (SIExtension)

+ (UIBezierPath *)bezierPathWithCurvedShadowForRect:(CGRect)rect
{
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	CGPoint topLeft		 = rect.origin;
	CGPoint bottomLeft	 = CGPointMake(0.f, CGRectGetHeight(rect) + offset);
	CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) - curve);
	CGPoint bottomRight	 = CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) + offset);
	CGPoint topRight	 = CGPointMake(CGRectGetWidth(rect), 0.f);
	
	[path moveToPoint:topLeft];
	[path addLineToPoint:bottomLeft];
	[path addQuadCurveToPoint:bottomRight controlPoint:bottomMiddle];
	[path addLineToPoint:topRight];
	[path addLineToPoint:topLeft];
	[path closePath];
	
	return path;
}

@end
