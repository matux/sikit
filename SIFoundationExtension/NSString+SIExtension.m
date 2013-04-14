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
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));

	return result;
}

- (NSString *)URLDecodedString
{
	NSString *result = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8));
	return result;	
}

- (NSString *)base64EncodedString
{
    NSData *data = [NSData dataWithBytes:[self UTF8String] length:[self length]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];

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
    static NSMutableCharacterSet *invisibleCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invisibleCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        [invisibleCharacterSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
        [invisibleCharacterSet formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
    });
    
    return ![[self stringByTrimmingCharactersInSet:invisibleCharacterSet] length];
}

- (BOOL)containsString:(NSString *)string
{
	return ([self rangeOfString:string].location != NSNotFound);
}

- (NSNumber *)toIntegerNumber
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
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

- (NSArray *)componentsSeparatedByHtmlTags
{
    NSMutableArray *html = [NSMutableArray arrayWithCapacity:64];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *tempText = nil;
    
    while( ![scanner isAtEnd] )
    {
        [scanner scanUpToString:@"<" intoString:&tempText];
        
        if (tempText != nil)
            [html addObject:tempText];
        
        [scanner scanUpToString:@">" intoString:NULL];
        
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        
        tempText = nil;
        
    }
    
    return html;
    
}

- (NSString *)stringByTrimmingHtmlTags
{    
    NSMutableString *html = [NSMutableString stringWithCapacity:[self length]];
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *tempText = nil;
    
    while( ![scanner isAtEnd] )
    {
        [scanner scanUpToString:@"<" intoString:&tempText];
        
        if (tempText != nil)
            [html appendString:tempText];
        
        [scanner scanUpToString:@">" intoString:NULL];
        
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        
        tempText = nil;
        
    }
    
    return html;
    
}

@end
