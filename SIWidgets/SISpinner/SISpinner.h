//
//  SISpinner.h
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SISpinner : UIView

@property (nonatomic, readwrite, assign) float progress;
@property (nonatomic, readwrite, assign) BOOL indefiniteMode;

- (void)startIndefiniteAnimation;
- (void)stopIndefiniteAnimation;
- (void)rotate;

@end
