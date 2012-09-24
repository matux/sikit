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

@class SIGridView;

@protocol SIGridViewDelegate <UIScrollViewDelegate>

@optional
- (void)gridView:(SIGridView *)gridView didSelectItemAtIndex:(int)index;
- (void)gridViewDidEnterLoadingMode:(SIGridView *)gridView;

@end

#pragma mark

@protocol SIGridViewDataSourceDelegate <NSObject>

@required
- (void)fetchData;
- (void)clearItems;

@end

#pragma mark

@interface SIGridView : UIScrollView
{
@protected
    SIMessageInterceptor *_delegate_interceptor;
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
@property (nonatomic, readwrite, retain) SISpinnerView *spinner;

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
