//
//  NSString+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "NSString+SIExtension.h"

@implementation NSString (SIExtension)

+ (NSString *)asciiStringWithString:(NSString *)string
{
	// @todo Agregar dierecis, ç, etc. //
	
	NSMutableString *originalString = [NSMutableString stringWithString:string];
	[originalString replaceOccurrencesOfString:@"á" withString:@"a" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [originalString length])];
	[originalString replaceOccurrencesOfString:@"é" withString:@"e" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [originalString length])];
	[originalString replaceOccurrencesOfString:@"í" withString:@"i" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [originalString length])];
	[originalString replaceOccurrencesOfString:@"ó" withString:@"o" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [originalString length])];
	[originalString replaceOccurrencesOfString:@"ú" withString:@"u" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [originalString length])];
	[originalString replaceOccurrencesOfString:@"ñ" withString:@"n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [originalString length])];
	
	return (NSString *)originalString;
	
}

+ (NSString *)stringWithInt:(int)n
{
	return [NSString stringWithFormat:@"%d", n];
}

- (NSString *)URLEncodedString 
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

- (NSString *)URLDecodedString
{
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
    [result autorelease];
	return result;	
}

- (NSString *)truncatedString:(int)characters charsLeftOut:(unsigned int *)charsLeftOut
{
    int originalLength = [self length];
    
    NSRange stringRange = {0, MIN([self length], characters)};
    stringRange = [self rangeOfComposedCharacterSequencesForRange:stringRange]; // adjust the range to include sequence chars
    NSString *truncatedString = [self substringWithRange:stringRange];
    
    if( charsLeftOut ) {
        int _charsLeftOut = originalLength - [truncatedString length];
        if( _charsLeftOut < 0 ) _charsLeftOut = 0;
        *charsLeftOut = _charsLeftOut;
    }
    
    return truncatedString;
}

- (NSString *)truncatedString:(int)characters
{
    return [self truncatedString:characters charsLeftOut:nil];
}

- (BOOL)isEmpty
{
	return [self length] == 0;
}

- (BOOL)isInvisible
{
    int length = [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    length += [[self stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]] length];
    length += [[self stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]] length];
    
    return length;
}

- (BOOL)containsString:(NSString *)string
{
	return ([self rangeOfString:string].location != NSNotFound);
}

- (NSNumber *)toIntegerNumber
{
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	return [formatter numberFromString:self];
}

- (NSDictionary *)parseQueryString
{
    NSString *normalizedQuery = [self stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *pairs = [normalizedQuery componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if( [elements count] > 1) {
            NSString *key = [elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            result[key] = value;
        }
    }
    
    return result;
}

@end
