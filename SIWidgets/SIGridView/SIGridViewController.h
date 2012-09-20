//
//  SIGridViewController.h
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIGridView.h"
#import "SIGridViewCell.h"

@interface SIGridViewController : UIViewController <SIGridViewDelegate, SIGridViewDataSourceDelegate>

@property (nonatomic, readwrite, retain) SIGridView *gridView;

@end
