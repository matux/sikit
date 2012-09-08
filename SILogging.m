//
//  SILogging.m
//  SIKit
//
//  Created by Matias Pequeno on 7/8/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SILogging.h"
#import "SIUtil.h"

#import <stdio.h>

void compactLog(NSString *format, ...)
{
    NSMutableString *s;
    
    if (format) {
        
        // Get a reference to the arguments that follow the format parameter
        va_list argList;
        va_start(argList, format);
        
        // Perform format string argument substitution, reinstate %% escapes, then print
        s = [[NSMutableString alloc] initWithFormat:format arguments:argList];
        [s replaceOccurrencesOfString:@"%%" withString:@"%%%%" options:0 range:NSMakeRange(0, [s length])];
        
        va_end(argList);
        
    } else {
        
        s = [[NSMutableString alloc] initWithString:@"\n"];
        
    }
    
    
    if( !LOGGING_DISABLE_LOCAL_OUTPUT ) {
        //printf("%s\n", [s UTF8String]);
        fprintf(stderr, "%s\n", [s UTF8String]);
    }
#if LOGGING_FORWARD_TO_TEST_FLIGHT
        TFLog(@"%@", s);
#endif
#if LOGGING_FORWARD_TO_CRASHLYTICS
        CLSLog(@"%@", s);
#endif
    
    [s release];
    
}

void compactLogAltFormat(NSString *namespace, int indentLevel, NSString *functionName, NSString *format, ...)
{
    // Showing namespace + level + thread
    NSString *prefix = [NSString stringWithFormat:@"[%@] %02d (%-*s", namespace, indentLevel, ((indentLevel*2)+3),
                        [[NSString stringWithFormat:@"%@):", [[NSThread currentThread] name]] cStringUsingEncoding:NSASCIIStringEncoding]];
    
    // Parse function name
    // if it starts with __nn, it means this is a block callback
    if( [functionName characterAtIndex:0] == '_' ) {
        
        // Parse callee
        NSRange functionRange = [functionName rangeOfString:@"]" options:NSBackwardsSearch];
        if( functionRange.length ) {
            functionName = [functionName substringWithRange:NSMakeRange(4, functionRange.location - 3)];
        }
        
        // Callback caller will be the 2nd object in the array
        NSString *callerName = [NSThread callStackSymbols][2];
        // Parse the caller call stack symbol
        BOOL isCCall = NO;
        NSRange callerRange = [callerName rangeOfString:@"[" options:NSBackwardsSearch];
        // If [ not found, it may be a C call
        if( !callerRange.length ) {
            callerRange = [callerName rangeOfString:@"_"];
            isCCall = callerRange.length; // != 0 == YES;
        }
        // If it is either an ObjC or a C call, parse it
        if( callerRange.length ) {
            callerName = [callerName substringWithRange:NSMakeRange(callerRange.location - 1, ([callerName length] - callerRange.location))];
            callerRange = [callerName rangeOfString:(isCCall?@"+":@"]") options:NSBackwardsSearch];
            if( callerRange.length )
                callerName = [callerName substringWithRange:NSMakeRange(0, callerRange.location + (isCCall?-1:1))];
        }
        
        // block in
        NSString *blockInString = isCCall ? @"()__block_in" : @"__block_in";
        
        // Build the absolute function name
        functionName = [NSString stringWithFormat:@"%@%@(%@)", callerName, blockInString, functionName];
        
    }
    
    if( format ) {
        
        // Get a reference to the arguments that follow the format parameter
        va_list argList;
        va_start(argList, format);
        
        // Perform format string argument substitution, reinstate %% escapes, then print
        NSMutableString *formattedString = [[NSMutableString alloc] initWithFormat:format arguments:argList];
        [formattedString replaceOccurrencesOfString:@"%%" withString:@"%%%%" options:0 range:NSMakeRange(0, [formattedString length])];
        
        va_end(argList);
        
        if( !LOGGING_DISABLE_LOCAL_OUTPUT ) {
            //printf("%s%s -> %s\n", [prefix UTF8String], [functionName UTF8String], [formattedString UTF8String]);
            fprintf(stderr, "%s%s -> %s\n", [prefix UTF8String], [functionName UTF8String], [formattedString UTF8String]);
        }
#if LOGGING_FORWARD_TO_TEST_FLIGHT
            TFLog(@"%@%@ -> %@", prefix, functionName, formattedString);
#endif
#if LOGGING_FORWARD_TO_CRASHLYTICS
            CLSLog(@"%@%@ -> %@", prefix, functionName, formattedString);
#endif
        
        [formattedString release];
        
    }
    else
    {
        if( !LOGGING_DISABLE_LOCAL_OUTPUT ) {
            //printf("%s%s\n", [prefix UTF8String], [functionName UTF8String]);
            fprintf(stderr, "%s%s\n", [prefix UTF8String], [functionName UTF8String]);
        }
#if LOGGING_FORWARD_TO_TEST_FLIGHT
            TFLog(@"%@%@", prefix, functionName);
#endif
#if LOGGING_FORWARD_TO_CRASHLYTICS
            CLSLog(@"%@%@", prefix, functionName);
#endif
    }
    
}
