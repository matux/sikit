//
//  NSStream.m
//  SIKit
//
//  Created by Matias Pequeno on 10/5/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "NSStream+SIExtension.h"

@implementation NSStream (SIExtension)

+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream
{
    CFHostRef           host;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    readStream = NULL;
    writeStream = NULL;
    
    host = CFHostCreateWithName(NULL, (__bridge CFStringRef) hostName);
    if( host ) 
    {
        (void)CFStreamCreatePairWithSocketToCFHost(NULL, host, port, &readStream, &writeStream);
        CFRelease(host);
    }
    
    if( !inputStream ) 
    {
        if( readStream ) 
            CFRelease(readStream);
    } 
    else 
        *inputStream = (NSInputStream *) CFBridgingRelease(readStream);

    if( !outputStream ) 
    {
        if( writeStream ) 
            CFRelease(writeStream);
    } 
    else 
        *outputStream = (NSOutputStream *) CFBridgingRelease(writeStream);
	
}

@end
