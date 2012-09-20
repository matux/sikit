//
//  SIGridView.m
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "SIMessageInterceptor.h"
#import "SISpinnerView.h"

@protocol SIGridViewDelegate <UIScrollViewDelegate>

@optional
- (void)didSelectItemAtIndex:(int)index;
- (void)didEnterLoadingMode;

@end

#pragma mark

@interface SIGridView : UIScrollView
{
@protected
    SIMessageInterceptor *_delegate_interceptor;
    SISpinnerView *_spinner;
    UILabel *_spinnerLabel;

    NSInteger *_columnHeights;
    NSInteger *_rowWidths;
    int _numberOfColumns;
    int _numberOfRows;
    int _lastVisibleItemIndex;
    BOOL _readyToLoadWhenReleased;

    UIView *_contentGridView;
}

@property (nonatomic, readwrite, retain) UIView *headerView;
@property (nonatomic, readwrite, retain) NSMutableArray *items;

@property (nonatomic, readwrite, assign) int columnWidth;
@property (nonatomic, readwrite, assign) int rowHeight;
@property (nonatomic, readwrite, assign) BOOL loading;
@property (nonatomic, readwrite, assign) BOOL loadMoreEnabled;
@property (nonatomic, readwrite, assign) BOOL horizontalModeEnabled;

@property (nonatomic, readwrite, unsafe_unretained) id <SIGridViewDelegate> delegate;

- (void)layoutCells;
- (void)clearCells;
- (void)addCell:(UIView *)cell;

@end
