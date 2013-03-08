//
//  NSString+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

@interface NSString (SIExtension)

+ (NSString *)asciiStringWithString:(NSString *)string;
+ (NSString *)stringWithInt:(int)n;

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

- (NSString *)base64EncodedString;

- (NSString *)truncatedString:(int)characters;
- (NSString *)truncatedString:(int)characters charsLeftOut:(unsigned int *)charsLeftOut;

- (BOOL)isEmpty;
- (BOOL)isInvisible; /*! @discussion checks for invisible characters as well as empty, could have a better name */
- (BOOL)isNullOrWhitespace;

- (BOOL)containsString:(NSString *)string;

- (NSNumber *)toIntegerNumber;

- (NSDictionary *)parseQueryString;

- (NSArray *)componentsSeparatedByHtmlTags;
- (NSString *)stringByTrimmingHtmlTags;

@end
