//
//  NSData+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 10/5/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "NSData+SIExtension.h"
#import "Base64Transcoder.h"

@implementation NSData (SIExtension)

+ (id)decodeBase64ForString:(NSString *)decodeString
{
    NSData *decodeBuffer = nil;
    // Must be 7-bit clean!
    NSData *tmpData = [decodeString dataUsingEncoding:NSASCIIStringEncoding];
    
    size_t estSize = EstimateBas64DecodedDataSize([tmpData length]);
    uint8_t* outBuffer = calloc(estSize, sizeof(uint8_t));
    
    size_t outBufferLength = estSize;
    if( Base64DecodeData([tmpData bytes], [tmpData length], outBuffer, &outBufferLength) )
    {
        decodeBuffer = [NSData dataWithBytesNoCopy:outBuffer length:outBufferLength freeWhenDone:YES];
    }
    else
    {
        free(outBuffer);
        [NSException raise:@"NSData+SIExtensionException" format:@"Unable to decode data!"];
    }
    
    return decodeBuffer;
	
}

+ (id)decodeWebSafeBase64ForString:(NSString *)decodeString
{
    return [NSData decodeBase64ForString:[[decodeString stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]];
	
}

- (NSString *)encodeBase64ForData
{
    NSString *encodedString = nil;
    
    // Make sure this is nul-terminated.
    size_t outBufferEstLength = EstimateBas64EncodedDataSize([self length]) + 1;
    char *outBuffer = calloc(outBufferEstLength, sizeof(char));
    
    size_t outBufferLength = outBufferEstLength;
    if( Base64EncodeNonWrappedData([self bytes], [self length], outBuffer, &outBufferLength) )
    {
        encodedString = @(outBuffer);
    }
    else
    {
        [NSException raise:@"NSData+SIExtensionException" format:@"Unable to encode data!"];
    }
    
    free(outBuffer);
    
    return encodedString;
	
}

- (NSString *)encodeWebSafeBase64ForData
{
    return [[[self encodeBase64ForData] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	
}

- (NSString *)encodeWrappedBase64ForData
{
    NSString *encodedString = nil;
    
    // Make sure this is nul-terminated.
    size_t outBufferEstLength = EstimateBas64EncodedDataSize([self length]) + 1;
    char *outBuffer = calloc(outBufferEstLength, sizeof(char));
    
    size_t outBufferLength = outBufferEstLength;
    if (Base64EncodeData([self bytes], [self length], outBuffer, &outBufferLength))
    {
        encodedString = @(outBuffer);
    }
    else
    {
        [NSException raise:@"NSData+SIExtensionException" format:@"Unable to encode data!"];
    }
    
    free(outBuffer);
    
    return encodedString;
	
}

@end
