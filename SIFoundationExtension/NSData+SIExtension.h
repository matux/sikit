//
//  NSData+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 10/5/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

@interface NSData (SIExtension)

+ (id)decodeBase64ForString:(NSString *)decodeString;
+ (id)decodeWebSafeBase64ForString:(NSString *)decodeString;

- (NSString *)encodeBase64ForData;
- (NSString *)encodeWebSafeBase64ForData;
- (NSString *)encodeWrappedBase64ForData;

@end
