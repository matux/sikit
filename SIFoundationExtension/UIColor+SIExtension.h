//
//  UIColor+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

typedef enum {
    CGComponentIndexRed = 0,
    CGComponentIndexGreen,
    CGComponentIndexBlue,
    CGComponentIndexAlpha,
    CGComponentIndexCount,
} CGComponentIndex;

#pragma mark -

@interface UIColor (SIExtension)

@property (readonly) CGFloat red;
@property (readonly) CGFloat green;
@property (readonly) CGFloat blue;
@property (readonly) CGFloat alpha;

+ (UIColor *)colorWithHex:(NSInteger)value;
+ (UIColor *)colorWithHex:(NSInteger)colorValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithRedInteger:(UInt8)red greenInteger:(UInt8)green blueInteger:(UInt8)blue alpha:(CGFloat)alpha;

- (CGFloat)colorFromComponentIndex:(NSInteger)index;

- (BOOL)isEqualToColor:(UIColor *)otherColor;

@end
