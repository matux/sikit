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
+ (AFImageCache *)af_sharedImageCache;
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image forURL:(NSURL *)url;
- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
@end

#pragma mark

static NSMutableArray *__imageRequestCollection = nil;

@interface SIURLConnectionDelegateForImageRequest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, readwrite, retain) UIImageView *imageView;
@property (nonatomic, readwrite, retain) NSURL *url;
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
    [_url release];
    
    [super dealloc];
}

- (void)finish
{
    [_imageView release];
    _imageView = nil;
    [_dataReceived release];
    _dataReceived = nil;
    [_url release];
    _url = nil;
    
    _finished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _statusCode = httpResponse.statusCode;
    _url = [httpResponse.URL retain];
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
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if( _statusCode == 200 )
    {
        _imageView.image = [UIImage imageWithData:_dataReceived];
        [[AFImageCache af_sharedImageCache] cacheImage:_imageView.image forURL:_url];
        if( [[_imageView class] respondsToSelector:@selector(animateWithDuration:animations:completion:)] )
        {
            _imageView.alpha = 0.f;
            [[_imageView class] animateWithDuration:.5f
                                         animations:^ {
                                             _imageView.alpha = 1.f;
                                         }
                                         completion:^(BOOL finished) {
                                             [self finish];
                                         }];
        }
        else
            [self finish];
    }
    else
        [self finish];
    
}

@end

#pragma mark

#endif

@implementation UIImageView (SIExtension)

#ifndef _AFNETWORKING_

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    if( [request respondsToSelector:@selector(setHTTPShouldUsePipelining:)] )
        [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    self.image = [[AFImageCache af_sharedImageCache] cachedImageForRequest:request];
    if( !self.image )
    {
        self.image = placeholderImage;
        
        SIURLConnectionDelegateForImageRequest *connection = [[[SIURLConnectionDelegateForImageRequest alloc] initWithImageView:self] autorelease];
        
        // Store connection so we can purge it later
        if( !__imageRequestCollection )
            __imageRequestCollection = [[NSMutableArray arrayWithCapacity:24] retain];
        else
        {
            // Purge previously created connections
            NSMutableArray *toDelete = [NSMutableArray array];
            for( SIURLConnectionDelegateForImageRequest *connection in __imageRequestCollection )
                if( connection.finished )
                    [toDelete addObject:connection];
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

+ (AFImageCache *)af_sharedImageCache
{
    static AFImageCache *_af_imageCache = nil;
    if( !_af_imageCache )
        _af_imageCache = [[AFImageCache alloc] init];
    return _af_imageCache;
}

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request
{
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    UIImage *cachedImage = [self objectForKey:[[request URL] absoluteString]];
    LogDebug(@"Cached %p with url: '%@'", cachedImage, [[request URL] absoluteString]);
	return cachedImage;
}

- (void)cacheImage:(UIImage *)image forURL:(NSURL *)url
{
    if( image && url ) {
        LogDebug(@"Caching image with url: '%@'", [url absoluteString]);
        [self setObject:image forKey:[url absoluteString]];
    }
}

- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request
{
    [self cacheImage:image forURL:[request URL]];
}

@end

#endif
