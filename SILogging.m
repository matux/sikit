//
//  SILogging.m
//  SIKit
//
//  Created by Matias Pequeno on 7/8/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#include "SILogging.h"
#include <stdio.h>

void compactLog(NSString *format, ...) 
{
    if (format == nil) 
    {
        printf("nil\n");
        return;
    }
    
    // Get a reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
    
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSMutableString *s = [[NSMutableString alloc] initWithFormat:format arguments:argList];
    [s replaceOccurrencesOfString:@"%%"
                       withString:@"%%%%"
                          options:0
                            range:NSMakeRange(0, [s length])];
    printf("%s\n", [s UTF8String]);

#if defined(LOGGING_FORWARD_TO_TEST_FLIGHT) && LOGGING_FORWARD_TO_TEST_FLIGHT
    TFLog(@"%@", s);
#endif
    
    [s release];
    
    va_end(argList);
    
}
