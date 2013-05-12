//
//  NSURLConnection+SIExtension.h
//  CanvassMate
//
//  Created by Matias Pequeno on 3/30/13.
//  Copyright (c) 2013 CanvassMate LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (SIExtension)

/*!
     @method       
        sendSynchronousRequest:queue:completionHandler:
     
     @abstract
         Performs a synchronous load of the given request.
         When the request has completed or failed, the block
         will be executed.
     
     @discussion
         This is a convenience routine that allows for
         synchronous loading of an url based resource.  If
         the resource load is successful, the data parameter
         to the callback will contain the resource data and
         the error parameter will be nil.  If the resource
         load fails, the data parameter will be nil and the
         error will contain information about the failure.
     
     @param
        request  The request to load. Note that the request is
                 deep-copied as part of the initialization
                 process. Changes made to the request argument after
                 this method returns do not affect the request that
                 is used for the loading process.
 
     @param
        handler  A block which receives the results of the resource load.
*/
+ (void)sendSynchronousRequest:(NSURLRequest *)request
             completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler;

@end
