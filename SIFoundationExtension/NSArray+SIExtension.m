//
//  NSArray+Extension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "NSArray+SIExtension.h"

@implementation NSArray (Extension)

- (BOOL)isEmpty
{
	return [self count] == 0;
}

- (NSDictionary *)indexKeyedDictionary
{
    NSUInteger arrayCount = [self count];
    
    __unsafe_unretained id arrayObjects[arrayCount], objectKeys[arrayCount];
    
    [self getObjects:arrayObjects range:NSMakeRange(0UL, arrayCount)];
    for( NSUInteger index = 0UL; index < arrayCount; index++) 
    { 
        objectKeys[index] = @(index); 
    }
    
    return [NSDictionary dictionaryWithObjects:arrayObjects forKeys:objectKeys count:arrayCount];
    
}

- (id)firstObject
{
    if( [self isEmpty] )
        return nil;
    else
        return self[0];
}

@end
