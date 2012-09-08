//
//  SIPopupView.h
//  SIKit
//
//  Created by Matias Pequeno on 8/9/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIPopupDisplayer.h"
#import "SIPopupView.h"

@implementation SIPopupDisplayer

- (id)initWithPopupView:(SIPopupView *)popupView
{
    if( self = [super init] )
    {
        _popupView = [popupView retain];
        [_popupView setParentPopupDisplayer:self];
        
        _backgroundView = [[UIView alloc] init];
        [_backgroundView setBackgroundColor:[UIColor colorWithWhite:.0f alpha:.4f]];
        [_backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    }

    return self;
}

- (void)dealloc 
{
    if( [_popupView superview] )
        [NSException raise:@"SIPopupIsVisibleException" format:@"- [UIPopup dealloc] reached while popup is still visible."];

    [_popupView release];
    [_backgroundView release];

    [super dealloc];
}

- (void)displayInView:(UIView *)otherView isModal:(BOOL)isModal 
{
    if( !isModal )
    {
        [otherView addSubview:_popupView];
    } 
	else
    {
        [_backgroundView setFrame:otherView.frame];
        [otherView addSubview:_backgroundView];
        [_backgroundView addSubview:_popupView];
    }

    [_popupView showAnimated:YES];
}

- (void)hide 
{
    [_popupView hideAnimated:YES];
    [_popupView removeFromSuperview];
    [_backgroundView removeFromSuperview];
}

- (void)displayInView:(UIView *)otherView during:(NSInteger)duration isModal:(BOOL)isModal 
{
    [self displayInView:otherView isModal:isModal];
    [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)displayInView:(UIView *)otherView whileBlock:(void(^)(void))block
{
    [self displayInView:otherView isModal:YES];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
		block();
		dispatch_async(dispatch_get_main_queue(), ^{
			[self hide];
		});
	});
}

@end
