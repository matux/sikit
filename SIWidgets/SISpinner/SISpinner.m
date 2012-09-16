//
//  SISpinner.h
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SISpinner.h"

@interface SISpinner ()

@property (nonatomic, readwrite, retain) UIImage *spinnerImage;
@property (nonatomic, readwrite, retain) NSTimer *indefiniteTimer;

@end

#pragma mark

@implementation SISpinner

- (id)init
{
    UIImage *containerImage = [UIImage imageNamed:@"containerImage"];
    
    if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, containerImage.size.width, containerImage.size.height)])
    {
        self.backgroundColor = [UIColor clearColor];
        self.spinnerImage = [UIImage imageNamed:@"spinner"];
    }
    
    return self;
}

- (void)dealloc
{
    [_indefiniteTimer invalidate];
    [_indefiniteTimer release];
    [_spinnerImage release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Public methods

- (void)rotate
{
    _progress += 1.5f;
    
    if( _progress >= 100.f )
        _progress -= 100.f;
    
    [self setNeedsDisplay];
}

- (void)startIndefiniteAnimation
{
    if( !_indefiniteMode )
    {
        @autoreleasepool {
            self.indefiniteTimer = [NSTimer scheduledTimerWithTimeInterval:0.025
                                                                    target:self
                                                                  selector:@selector(rotate)
                                                                  userInfo:nil
                                                                   repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_indefiniteTimer
                                      forMode:NSRunLoopCommonModes];
            
            _indefiniteMode = YES;
        }
    }
}

- (void)stopIndefiniteAnimation
{
    if( _indefiniteMode )
    {
        [_indefiniteTimer invalidate];
        self.indefiniteTimer = nil;
        _indefiniteMode = NO;
    }
}

- (void)setProgress:(float)progress
{    
    _progress = progress;
    
    [self setNeedsDisplay];
}

#pragma mark
#pragma mark UIViewRendering

- (void)drawRect:(CGRect)rect
{    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize size = _spinnerImage.size;
    rect = CGRectMake(rect.origin.x + 4, rect.origin.y + 4, size.width, size.height);
    if( !_indefiniteMode )
    {
        UIGraphicsBeginImageContext(size);
        CGContextRef maskContext = UIGraphicsGetCurrentContext();
        
        CGContextMoveToPoint(maskContext, CGRectGetWidth(rect) / 2.0f, CGRectGetHeight(rect) / 2.0f);
        CGContextAddArc(maskContext, CGRectGetWidth(rect) / 2.0f, CGRectGetHeight(rect) / 2.0f, CGRectGetWidth(rect) / 2.0f, (0.0f * M_PI / 180.0f) + (90 * M_PI / 180.0f),  ((360 * ((100 - _progress) / 100.0f)) * M_PI / 180.0f) + (90 * M_PI / 180.0f), 1) ;
        CGContextClosePath(maskContext);
        CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
        CGContextFillPath(maskContext);
        CGContextDrawPath(maskContext, kCGPathFillStroke);
        
        UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGContextClipToMask(context, rect, mask.CGImage);
    }
    
    float progress = 0.75 + (_progress / 400);
   
    UIImage *rotatedImage = SIRotateImageByRadians(_spinnerImage, ((_progress / 100) * 360) * (M_PI / 180));
    [rotatedImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:_indefiniteMode ? 1.0 : progress];
}

@end
