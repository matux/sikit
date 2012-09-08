//
//  NSURL+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "NSURL+SIExtension.h"

@implementation NSURL (SIExtension)

- (NSString *)URLStringWithoutQuery 
{
    NSArray *parts = [[self absoluteString] componentsSeparatedByString:@"?"];
    return parts[0];
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent
{
	NSString *fullStringURL = [NSString stringWithFormat:@"%@://%@%@/%@", [self scheme], [self host], [self path], pathComponent];
	if( [self query] )
		fullStringURL = [fullStringURL stringByAppendingFormat:@"?%@", [self query]];
	return [NSURL URLWithString:fullStringURL];
}

@end
