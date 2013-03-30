//
//  NSURLConnection+SIExtension.m
//  CanvassMate
//
//  Created by Matias Pequeno on 3/30/13.
//  Copyright (c) 2013 CanvassMate LLC. All rights reserved.
//

#import "NSURLConnection+SIExtension.h"

@implementation NSURLConnection (SIExtension)

+ (void)sendSynchronousRequest:(NSURLRequest *)request
             completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSURLResponse *response = nil;
    NSData *data = nil;
    NSError *error = nil;
    
    data = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (handler)
        handler(response, data, error);
}

@end
