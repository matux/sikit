//
//  NSUrl+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

@interface NSURL (SIExtension)

- (NSString *)URLStringWithoutQuery;
- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent;

@end
