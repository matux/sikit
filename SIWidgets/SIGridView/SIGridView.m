//
//  SIGridView.m
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIGridView.h"

@implementation SIGridView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _delegate_interceptor = [[SIMessageInterceptor alloc] init];
        [_delegate_interceptor setMiddleMan:self];
        [super setDelegate:(id)_delegate_interceptor];
        
        self.backgroundColor = [UIColor clearColor];
        self.items = [NSMutableArray array];
        self.scrollEnabled = YES;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        _contentGridView = [[UIView alloc] init];
        [self addSubview:_contentGridView];
        
        _readyToLoadWhenReleased = NO;
        _lastVisibleItemIndex = 0;
        
        _loading = NO;
        _loadMoreEnabled = YES;
    }
    
    return self;
    
}

- (void)initialize
{
    free(_columnHeights);
    free(_rowWidths);
    
    if( !_horizontalModeEnabled )
    {
        if( _loadMoreEnabled )
            [_spinner setFrame:CGRectMake(self.bounds.size.width/2 - 20, 20, 20, 20)];
        
        LogGridView(@"width: %f", self.bounds.size.width);
        _numberOfColumns = self.bounds.size.width / (float)_columnWidth;
        _columnHeights = (NSInteger *)calloc(_numberOfColumns, sizeof(NSInteger));
        for( NSInteger i = 0; i < _numberOfColumns; i++ )
            _columnHeights[i] = 0;
    }
    else
    {
        if( _loadMoreEnabled )
            [_spinner setFrame:CGRectMake(20, self.bounds.size.height/2 - 20, 20, 20)];
        
        //if( _loadMoreEnabled )
        //    [spinner setFrame:CGRectMake(20, self.bounds.size.height/2 - 20, 20, 20)];
        
        _numberOfRows = self.bounds.size.height / (float)_rowHeight;
        LogGridView(@"r: %f", self.bounds.size.height);
        _rowWidths = (NSInteger *)calloc(_numberOfRows, sizeof(NSInteger));
        for( NSInteger i = 0; i < _numberOfRows; i++ )
            _rowWidths[i] = 0;
    }
    
}

- (int)shortestColumnIndex
{
    int shortestIndex = 0;
    int shortestColumnHeight = INT_MAX; //9999999;
    
    for( int i = 0; i < _numberOfColumns; i++ )
    {
        if( _columnHeights[i] < shortestColumnHeight )
        {
            shortestColumnHeight = _columnHeights[i];
            shortestIndex = i;
        }
    }
    
    return shortestIndex;
    
}

- (int)shortestRowIndex
{    
    int shortestIndex = 0;
    int shortestRowWidth = INT_MAX; //9999999;
    
    for( int i = 0; i < _numberOfRows; i++ )
    {
        if( _rowWidths[i] < shortestRowWidth )
        {
            shortestRowWidth = _rowWidths[i];
            shortestIndex = i;
        }
    }
    
    return shortestIndex;
    
}

- (void)setContentSizeAuto
{
    if( self.horizontalModeEnabled )
    {
        float longestRowWidth = 0.0;
        for( int i = 0; i < _numberOfRows; i++ )
        {
            if( _rowWidths[i] > longestRowWidth )
                longestRowWidth = _rowWidths[i];
        }
        
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             if( (longestRowWidth + 20) > self.frame.size.width )
                                 [self setContentSize:CGSizeMake(longestRowWidth + 50, self.frame.size.height)];
                             else
                                 [self setContentSize:CGSizeMake(self.frame.size.width + 1, self.bounds.size.height)];
                         }
                         completion:nil];
    }
    else
    {
        float longestColumnHeight = 0.f;
        for( int i = 0; i < _numberOfColumns; i++ )
            if( _columnHeights[i] > longestColumnHeight )
                longestColumnHeight = _columnHeights[i];
        
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             if (longestColumnHeight + 20 + _headerView.frame.size.height > self.frame.size.height)
                                 [self setContentSize:CGSizeMake(self.frame.size.width, longestColumnHeight + 50 + _headerView.frame.size.height)];
                             else
                                 [self setContentSize:CGSizeMake(self.frame.size.width, self.bounds.size.height+1)];
                         }
                         completion:nil];
    }
    
    [_contentGridView setFrame:CGRectMake(0, _headerView.frame.size.height, self.contentSize.width, self.contentSize.height)];
    
}

- (void)placeItem:(UIView *)item :(int)shortestIndex :(int)top :(int)left
{
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         [item setFrame:CGRectMake(left, top, item.frame.size.width, item.frame.size.height)];
                         item.alpha = 1.0;
                     }
                     completion:nil];
    
    if( _horizontalModeEnabled ) {
        int newWidth = left + item.frame.size.width;
        _rowWidths[shortestIndex] = newWidth;
    } else {
        int newHeight = top + item.frame.size.height;
        _columnHeights[shortestIndex] = newHeight;
    }
    
    [self setContentSizeAuto];
    
}

- (void)repositionItem:(UIView *)item
{
    int shortestIndex, top, left;
    
    if( self.horizontalModeEnabled )
    {
        shortestIndex = [self shortestRowIndex];
        top = shortestIndex * _rowHeight;
        left = _rowWidths[shortestIndex];
        
        int newWidth = left + item.frame.size.width;
        _rowWidths[shortestIndex] = newWidth;
    }
    else
    {
        shortestIndex = [self shortestColumnIndex];
        top = _columnHeights[shortestIndex];
        left = (shortestIndex * _columnWidth);
        
        int newHeight = top+item.frame.size.height;
        _columnHeights[shortestIndex] = newHeight;
    }
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations: ^ {
                         [item setFrame:CGRectMake(left, top, item.frame.size.width, item.frame.size.height)];
                     }
                     completion:nil];
}

- (void)handleCellTap:(UITapGestureRecognizer *)sender
{
    [self.delegate gridView:self didSelectItemAtIndex:sender.view.tag];
}

- (void)addCell:(UIView *)cell
{
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellTap:)];
    [cell addGestureRecognizer:singleFingerTap];
    
    UIView *item = [[UIView alloc] init];
    
    int shortestIndex, top, left;
    
    if( _horizontalModeEnabled )
    {
        shortestIndex = [self shortestRowIndex];
        top = shortestIndex * _rowHeight;
        left = _rowWidths[shortestIndex];
    
        [item setFrame:CGRectMake(left-50, top, cell.frame.size.width, _rowHeight)];
    }
    else
    {
        shortestIndex = [self shortestColumnIndex];
        top = _columnHeights[shortestIndex];
        left = shortestIndex * _columnWidth;
        
        [item setFrame:CGRectMake(left, top - 50, _columnWidth, cell.frame.size.height)];
    }
    
    item.alpha = 0.f;
    [item addSubview:cell];
    item.clipsToBounds = YES;
    [self.items addObject:item];
    [_contentGridView addSubview:item];
    
    [self placeItem:item :shortestIndex :top :left];
    
}

- (void)layoutCells
{
    [self initialize];
    
    for( UIView *item in self.items )
        [self repositionItem:item];
    
    // scroll to the last visible item
    if( _lastVisibleItemIndex != 0 )
    {
        UIView *lastVisibleItem = [self.items objectAtIndex:_lastVisibleItemIndex];
        [self setContentOffset:(_horizontalModeEnabled ?
                                CGPointMake(lastVisibleItem.frame.origin.x, 0) :
                                CGPointMake(0, lastVisibleItem.frame.origin.y))
                      animated:NO];
    }
    
    [self setContentSizeAuto];
    
    // position the spinner
    if( [self.items count] && _loadMoreEnabled )
    {
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations: ^ {
                             _spinner.alpha = 1;
                             if (_horizontalModeEnabled) {
                                 [_spinner setFrame:CGRectMake(self.contentSize.width-20, self.bounds.size.height/2 - 20, 20, 20)];
                                 [_spinnerLabel setFrame:CGRectMake(_spinner.frame.origin.x + 50, self.bounds.size.height/2 - 20, _spinnerLabel.frame.size.width, _spinnerLabel.frame.size.height)];
                             } else {
                                 [_spinner setFrame:CGRectMake(self.bounds.size.width/2 - 20, self.contentSize.height-20, 20, 20)];
                                 [_spinnerLabel setFrame:CGRectMake(self.bounds.size.width/2 - 100, _spinner.frame.origin.y + 50, _spinnerLabel.frame.size.width, _spinnerLabel.frame.size.height)];
                             }
                         }
                         completion:nil];
    }
}

- (void)clearCells
{
    for( UIView *view in _items )
        [view removeFromSuperview];
    
    _items = [NSMutableArray array];
    _lastVisibleItemIndex = 0;
    
    [self initialize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( _loadMoreEnabled )
    {
        BOOL isReady = NO;
        
        // make a visible item check, every 10 pixels scrolled
        // and make the spinner fill itself rotating    
        if( _horizontalModeEnabled )
        {
            if( ((int)scrollView.contentOffset.y % 10) == 0 ) {
                for( UIView *item in _items )
                    if (scrollView.contentOffset.y > item.frame.origin.y)
                        _lastVisibleItemIndex = [_items indexOfObject:item];
            }
            
            if( (scrollView.contentOffset.x + scrollView.frame.size.width) > scrollView.contentSize.width )
            {
                float diff = scrollView.contentOffset.x + scrollView.frame.size.width - scrollView.contentSize.width;
                if( diff <= 100.0 )
                    _spinner.progress = diff - 1;
            }
            
            if( (scrollView.contentOffset.x + scrollView.frame.size.width) > (scrollView.contentSize.width + 100) )
                isReady = YES;
        }
        else
        {
            if( ((int)scrollView.contentOffset.x % 10) == 0 )
            {
                for( UIView *item in _items )
                    if( scrollView.contentOffset.x > item.frame.origin.x )
                        _lastVisibleItemIndex = [_items indexOfObject:item];
            }
            
            if( (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height )
            {
                float diff = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
                if( diff <= 100.0 )
                    _spinner.progress = diff - 1;
            }
            
            if( (scrollView.contentOffset.y + scrollView.frame.size.height) > (scrollView.contentSize.height + 100) )
                isReady = YES;
        }
        
        // handle the loading action when released
        if( isReady )
        {
            if( !_loading )
            {
                _readyToLoadWhenReleased = YES;
                [UIView beginAnimations:@"FadeAnimations" context:nil];
                [UIView setAnimationDuration:0.2f]; 
                _spinnerLabel.alpha = 1;
                [UIView commitAnimations];            
            }
        }
        else
        {
            _readyToLoadWhenReleased = NO;
            [UIView beginAnimations:@"FadeAnimations" context:nil];
            [UIView setAnimationDuration:0.2f]; 
            _spinnerLabel.alpha = 0;
            [UIView commitAnimations];
        }
    }
    
    // also notify the delegate's method
    if( [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)] )
        [self.delegate scrollViewDidScroll:scrollView];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( !_loadMoreEnabled )
        return;
    
    // start loading when dragging is released
    if( _readyToLoadWhenReleased && !_loading )
    {
        [self.delegate gridViewDidEnterLoadingMode:self];
        
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                                 [self setContentSize:(_horizontalModeEnabled ?
                                                       CGSizeMake(self.contentSize.width + 40, 0) :
                                                       CGSizeMake(0, self.contentSize.height + 40))];
                         }
                         completion:nil];
    }
    
}

#pragma mark
#pragma mark Custom Getter and Setters

- (id)delegate
{
    return _delegate_interceptor.receiver;
}

- (void)setDelegate:(id)newDelegate
{
    [super setDelegate:nil];
    [_delegate_interceptor setReceiver:newDelegate];
    [super setDelegate:(id)_delegate_interceptor];
}

- (void)setHeaderView:(UIView *)input
{
    if( _headerView )
        [_headerView removeFromSuperview];
    
    _headerView = input;
    [self addSubview:_headerView];
    [_contentGridView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_contentGridView setFrame:CGRectMake(0, _headerView.frame.size.height, self.contentSize.width, self.contentSize.height)];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if( _loadMoreEnabled )
    {
        if( !_loading )
        {
            _readyToLoadWhenReleased = NO;
            [_spinner stopIndefiniteMode];
            
            [UIView animateWithDuration:0.3f  animations:^ {
                if( _horizontalModeEnabled ) {
                    [_spinner setFrame:CGRectMake(self.contentSize.width - 20, self.frame.size.height / 2 - 20, 20, 20)];
                    [_spinnerLabel setFrame:CGRectMake(_spinner.frame.origin.x + 50, self.frame.size.height / 2 - 20, _spinnerLabel.frame.size.width, _spinnerLabel.frame.size.height)];
                } else {
                    [_spinner setFrame:CGRectMake(self.frame.size.width / 2 - 20, self.contentSize.height - _headerView.frame.size.height - 20, 20, 20)];
                    [_spinnerLabel setFrame:CGRectMake(self.frame.size.width / 2 - 100, _spinner.frame.origin.y + 50, _spinnerLabel.frame.size.width, _spinnerLabel.frame.size.height)];
                }
            }];
        }
        else
        {
            [_spinner startIndefiniteMode];
        }
    }
}

- (void)setLoadMoreEnabled:(BOOL)loadMoreEnabled
{
    _loadMoreEnabled = loadMoreEnabled;
    
    if( [_contentGridView.subviews containsObject:_spinner] )
        [_spinner removeFromSuperview];
    
    if( _loadMoreEnabled )
    {
        _spinner = [[SISpinnerView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - 20, 20, 20, 20)];
        [_contentGridView addSubview:_spinner];
        
        _spinnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - 100, 60, 200, 40)];
        _spinnerLabel.textAlignment = UITextAlignmentCenter;
        _spinnerLabel.text = @"Release to load more";
        _spinnerLabel.backgroundColor = [UIColor clearColor];
        _spinnerLabel.textColor = [UIColor whiteColor];
        _spinnerLabel.alpha = 0;
        [_contentGridView addSubview:_spinnerLabel];
    }
}

- (void)setHorizontalModeEnabled:(BOOL)value
{
    _horizontalModeEnabled = value;
    [self initialize];
}

@end
