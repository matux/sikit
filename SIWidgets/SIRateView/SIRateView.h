//
//  SIRateView.h
//  Crunch
//
//  Created by Matias Pequeno on 9/24/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SIRateView;

@protocol SIRateViewDelegate <NSObject>
@required
- (void)rateView:(SIRateView *)rateView ratingDidChange:(float)rating;
@end

#pragma mark

@interface SIRateView : UIView

@property (nonatomic, readwrite, retain) UIImage *notSelectedImage;
@property (nonatomic, readwrite, retain) UIImage *halfSelectedImage;
@property (nonatomic, readwrite, retain) UIImage *fullSelectedImage;

@property (nonatomic, readwrite, assign) float rating;

@property (nonatomic, readwrite, assign) BOOL editable;
@property (nonatomic, readwrite, assign) int maxRating;

@property (nonatomic, readwrite, retain) NSMutableArray *imageViews;
@property (nonatomic, readwrite, assign) int midMargin;
@property (nonatomic, readwrite, assign) int leftMargin;
@property (nonatomic, readwrite, assign) CGSize minImageSize;

@property (nonatomic, readwrite, assign) id <SIRateViewDelegate> delegate;

@end
