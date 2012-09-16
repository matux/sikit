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
    SIMessageInterceptor *delegate_interceptor;
    SISpinnerView *spinner;
    UILabel *spinnerLabel;
    BOOL loading;
    BOOL loadMoreEnabled;
    BOOL horizontalModeEnabled;
    NSInteger *columnHeights;
    NSInteger *rowWidths;
    int numberOfColumns;
    int numberOfRows;
    int lastVisibleItemIndex;
    int columnWidth;
    int rowHeight;
    BOOL readyToLoadWhenReleased;
    id <SIGridViewDelegate> delegate;
    UIView *headerView;
    UIView *contentView;
}

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *items;
@property int columnWidth;
@property int rowHeight;
@property BOOL loading;
@property BOOL loadMoreEnabled;
@property BOOL horizontalModeEnabled;
@property (nonatomic, unsafe_unretained) id <SIGridViewDelegate> delegate;

- (void)layoutCells;
- (void)clearCells;
- (void)addCell:(UIView *)cell;

@end
