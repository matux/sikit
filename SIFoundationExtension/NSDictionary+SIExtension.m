//
//  NSDictionary+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "NSDictionary+SIExtension.h"

@implementation NSDictionary (SIExtension)

- (NSString *)stringForKey:(id)key
{
	id obj = [self objectForKey:key];
    return (obj == [NSNull null] || ![obj isKindOfClass:[NSString class]]) ? nil : obj;
}

- (NSNumber *)numberForKey:(id)key
{
	id obj = [self objectForKey:key];
    return (obj == [NSNull null] || ![obj isKindOfClass:[NSNumber class]]) ? nil : obj;
}

- (NSMutableDictionary *)dictionaryForKey:(id)key
{
	id obj = [self objectForKey:key];
    return (obj == [NSNull null] || ![obj isKindOfClass:[NSMutableDictionary class]]) ? nil : obj;
}

- (NSMutableArray *)arrayForKey:(id)key
{
	id obj = [self objectForKey:key];
    return (obj == [NSNull null] || ![obj isKindOfClass:[NSMutableArray class]]) ? nil : obj;
}

@end
