//
//  UIImageView+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "UIImageView+SIExtension.h"

#ifndef _AFNETWORKING_

#pragma mark

@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
@end

#pragma mark

static NSMutableArray *__imageRequestCollection = nil;

@interface SIURLConnectionDelegateForImageRequest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, readwrite, retain) UIImageView *imageView;
@property (nonatomic, readonly, assign) BOOL finished;
- (id)initWithImageView:(UIImageView *)imageView;
@end

@implementation SIURLConnectionDelegateForImageRequest
{
    int _statusCode;
    NSMutableData *_dataReceived;
}

- (id)initWithImageView:(UIImageView *)imageView
{
    if( self = [super init] ) {
        _imageView = [imageView retain];
        _finished = NO;
    }
    return self;
}

- (void)dealloc
{
    [_imageView release];
    [_dataReceived release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _statusCode = httpResponse.statusCode;
    if( _statusCode == 200 )
        _dataReceived = [[NSMutableData data] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if( _statusCode == 200 )
        [_dataReceived appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_imageView release];
    _imageView = nil;
    [_dataReceived release];
    _dataReceived = nil;
    
    _finished = YES;    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if( _statusCode == 200 )
        _imageView.image = [UIImage imageWithData:_dataReceived];
    
    [_imageView release];
    _imageView = nil;
    [_dataReceived release];
    _dataReceived = nil;
    
    _finished = YES;
}

@end

#pragma mark

#endif

@implementation UIImageView (SIExtension)

#ifndef _AFNETWORKING_

+ (AFImageCache *)af_sharedImageCache
{
    static AFImageCache *_af_imageCache = nil;
    if( !_af_imageCache )
        _af_imageCache = [[AFImageCache alloc] init];    
    return _af_imageCache;
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    self.image = [[[self class] af_sharedImageCache] cachedImageForRequest:request];
    if( !self.image )
    {
        self.image = placeholderImage;
        
        SIURLConnectionDelegateForImageRequest *connection = [[SIURLConnectionDelegateForImageRequest alloc] initWithImageView:self]; // (*1) First alloc
        
        // Store connection so we can purge it later
        if( !__imageRequestCollection )
            __imageRequestCollection = [NSMutableArray arrayWithCapacity:12];
        else {
            // Purge previously created connections
            NSMutableArray *toDelete = [NSMutableArray array];
            for( SIURLConnectionDelegateForImageRequest *connection in __imageRequestCollection )
                if( connection.finished ) {
                    [toDelete addObject:connection];
                    [connection release]; // This releases the first alloc (*1)
                }
            [__imageRequestCollection removeObjectsInArray:toDelete];
            [toDelete removeAllObjects];
        }
        // Store current connection
        [__imageRequestCollection addObject:connection];
        
        // Try to get the image
        [NSURLConnection connectionWithRequest:request delegate:connection];
    }
}

#endif

@end

#ifndef _AFNETWORKING_

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request
{
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
	return [self objectForKey:[[request URL] absoluteString]];
}

- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:[[request URL] absoluteString]];
    }
}

@end

#endif
