//
//  SISpinnerView.h
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SISpinner.h"

@interface SISpinnerView : UIView

@property (nonatomic, readwrite, assign) CGFloat progress;
@property (nonatomic, readonly, assign) BOOL indefinite;

- (void)startIndefiniteMode;
- (void)stopIndefiniteMode;

@end
