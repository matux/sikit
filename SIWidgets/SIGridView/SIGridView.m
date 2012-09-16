//
//  SIGridView.m
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIGridView.h"

@implementation SIGridView

@synthesize items;
@synthesize rowHeight, columnWidth; 

- (void)setHeaderView:(UIView *)input
{
    headerView = input;
    [self addSubview:headerView];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [contentView setFrame:CGRectMake(0, self.headerView.frame.size.height, self.contentSize.width, self.contentSize.height)];
}

- (UIView *)headerView
{
    return headerView;
}

- (id)delegate
{
    return delegate_interceptor.receiver; 
}

- (void)setDelegate:(id)newDelegate
{
    [super setDelegate:nil];
    [delegate_interceptor setReceiver:newDelegate];
    [super setDelegate:(id)delegate_interceptor];
}

- (BOOL)loading
{
    return loading;
}

- (void)setLoading:(BOOL)value
{
    loading = value;
    if (self.loadMoreEnabled == YES) {
        if (value == NO) {
            readyToLoadWhenReleased = NO;
            [spinner stopIndefiniteMode];
            
            [UIView animateWithDuration:0.3f  animations:^{
                if (self.horizontalModeEnabled) {
                    [spinner setFrame:CGRectMake(self.contentSize.width-20, self.frame.size.height/2 -20, 20, 20)];
                    [spinnerLabel setFrame:CGRectMake(spinner.frame.origin.x + 50, self.frame.size.height/2 - 20, spinnerLabel.frame.size.width, spinnerLabel.frame.size.height)];
                }
                else {
                    [spinner setFrame:CGRectMake(self.frame.size.width/2 - 20, self.contentSize.height-headerView.frame.size.height-20, 20, 20)];
                    [spinnerLabel setFrame:CGRectMake(self.frame.size.width/2 - 100, spinner.frame.origin.y + 50, spinnerLabel.frame.size.width, spinnerLabel.frame.size.height)];
                }
            }];
        }
        else {
            [spinner startIndefiniteMode];
        }
    }
}

- (BOOL)loadMoreEnabled
{
    return loadMoreEnabled;
}

- (void)setLoadMoreEnabled:(BOOL)value
{    
    loadMoreEnabled = value;
    
    if ([contentView.subviews containsObject:spinner]) {
        [spinner removeFromSuperview];
    }
    
    if (value == YES) {
        spinner = [[SISpinnerView alloc] init];
        [spinner setFrame:CGRectMake(self.bounds.size.width/2 - 20, 20, 20, 20)];
        [contentView addSubview:spinner];
        
        spinnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 100, 60, 200, 40)];
        spinnerLabel.textAlignment = UITextAlignmentCenter;
        spinnerLabel.text = @"Release to load more";
        spinnerLabel.backgroundColor = [UIColor clearColor];
        spinnerLabel.textColor = [UIColor whiteColor];
        spinnerLabel.alpha = 0;
        [contentView addSubview:spinnerLabel];     
    }
}

- (BOOL)horizontalModeEnabled
{
    return horizontalModeEnabled;
}

- (void)setHorizontalModeEnabled:(BOOL)value
{
    horizontalModeEnabled = value;
    [self initialize];
}

- (void)initialize
{    
    free(columnHeights);
    free(rowWidths);
    
    if (horizontalModeEnabled == NO) {
        if (self.loadMoreEnabled == YES) {
            [spinner setFrame:CGRectMake(self.bounds.size.width/2 - 20, 20, 20, 20)];
        }
        NSLog(@"width: %f", self.bounds.size.width);
        numberOfColumns = self.bounds.size.width / (float)columnWidth;
        columnHeights = (NSInteger*)calloc(numberOfColumns, sizeof(NSInteger));
        for (NSInteger i = 0; i < numberOfColumns; i++)
            columnHeights[i] = 0;
    }
    else  {
        if (self.loadMoreEnabled == YES) {
            [spinner setFrame:CGRectMake(20, self.bounds.size.height/2 - 20, 20, 20)];
        }
        
        if (self.loadMoreEnabled == YES) {
            [spinner setFrame:CGRectMake(20, self.bounds.size.height/2 - 20, 20, 20)];
        }
        
        numberOfRows = self.bounds.size.height / (float)rowHeight;
        NSLog(@"r: %f", self.bounds.size.height);
        rowWidths = (NSInteger*)calloc(numberOfRows, sizeof(NSInteger));
        for (NSInteger i = 0; i < numberOfRows; i++)
            rowWidths[i] = 0;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        delegate_interceptor = [[SIMessageInterceptor alloc] init];
        [delegate_interceptor setMiddleMan:self];
        [super setDelegate:(id)delegate_interceptor];
        
        self.backgroundColor = [UIColor clearColor];
        self.items = [NSMutableArray array];
        self.scrollEnabled = YES;
        [self setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        readyToLoadWhenReleased = NO;
        lastVisibleItemIndex = 0;
        
        self.loading = NO;
        self.loadMoreEnabled = YES;
    }
    
    return self;
    
}

- (int)shortestColumnIndex
{
    int shortestIndex = 0;
    int shortestColumnHeight = 9999999;
    for (int i=0; i<numberOfColumns; i++) {
        if (columnHeights[i]<shortestColumnHeight){
            shortestColumnHeight = columnHeights[i];
            shortestIndex = i;
        }
    }
    return shortestIndex;
}

- (int)shortestRowIndex
{    
    int shortestIndex = 0;
    int shortestRowWidth = 9999999;
    for (int i=0; i<numberOfRows; i++)
    {
        if (rowWidths[i]<shortestRowWidth)
        {
            shortestRowWidth = rowWidths[i];
            shortestIndex = i;
        }
    }
    
    return shortestIndex;
    
}

- (void)setContentSizeAuto
{
    if (self.horizontalModeEnabled)
    {
        float longestRowWidth = 0.0;
        for (int i=0; i<numberOfRows; i++)
        {
            if (rowWidths[i]>longestRowWidth)
                longestRowWidth = rowWidths[i];
        }
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations: ^ {
            if (longestRowWidth + 20 > self.frame.size.width)
                [self setContentSize:CGSizeMake(longestRowWidth + 50, self.frame.size.height)];
            else 
                [self setContentSize:CGSizeMake(self.frame.size.width + 1, self.bounds.size.height)];        
        }
        completion:nil];
    }
    else
    {
        float longestColumnHeight = 0.0;
        for (int i=0; i<numberOfColumns; i++)
        {
            if (columnHeights[i]>longestColumnHeight)
                longestColumnHeight = columnHeights[i];
        }
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
            if (longestColumnHeight + 20 + headerView.frame.size.height > self.frame.size.height)
                [self setContentSize:CGSizeMake(self.frame.size.width, longestColumnHeight + 50 + headerView.frame.size.height)];
            else 
                [self setContentSize:CGSizeMake(self.frame.size.width, self.bounds.size.height+1)];        
        }
        completion:nil];
    }
    
    [contentView setFrame:CGRectMake(0, self.headerView.frame.size.height, self.contentSize.width, self.contentSize.height)];
}

- (void)placeItem:(UIView *)item :(int)shortestIndex :(int)top :(int)left
{
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
        [item setFrame:CGRectMake(left, top, item.frame.size.width, item.frame.size.height)];
        item.alpha = 1.0;
    }
    completion:nil]; 
    
    if (self.horizontalModeEnabled) {
        int newWidth = left+item.frame.size.width;
        rowWidths[shortestIndex] = newWidth;
    }
    else {
        int newHeight = top+item.frame.size.height;
        columnHeights[shortestIndex] = newHeight;
    }
    
    [self setContentSizeAuto];
}

- (void) repositionItem:(UIView *)item {
    
    int shortestIndex;
    int top;
    int left;
    
    if (self.horizontalModeEnabled) {
        shortestIndex = [self shortestRowIndex];
        top = (shortestIndex * rowHeight);
        left = rowWidths[shortestIndex];
        
        int newWidth = left+item.frame.size.width;
        rowWidths[shortestIndex] = newWidth;
    }
    else {
        shortestIndex = [self shortestColumnIndex];
        top = columnHeights[shortestIndex];
        left = (shortestIndex * columnWidth);
        
        int newHeight = top+item.frame.size.height;
        columnHeights[shortestIndex] = newHeight;
    }
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
        [item setFrame:CGRectMake(left, top, item.frame.size.width, item.frame.size.height)];
    }
    completion:nil]; 
}

- (void) handleCellTap:(UITapGestureRecognizer *)sender {
    [self.delegate didSelectItemAtIndex:sender.view.tag];
}

- (void) addCell:(UIView *) cell {
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellTap:)];
    [cell addGestureRecognizer:singleFingerTap];
    
    UIView *item = [[UIView alloc] init];
    
    int shortestIndex;
    int top;
    int left;
    
    if (self.horizontalModeEnabled) {
        shortestIndex = [self shortestRowIndex];
        top = (shortestIndex * rowHeight);
        left = rowWidths[shortestIndex];        
    
        [item setFrame:CGRectMake(left-50, top, cell.frame.size.width, rowHeight)];
    }
    else {
        shortestIndex = [self shortestColumnIndex];
        top = columnHeights[shortestIndex];
        left = (shortestIndex * columnWidth);
        
        [item setFrame:CGRectMake(left, top-50, columnWidth, cell.frame.size.height)];
    }
    
    item.alpha = 0.0;
    [item addSubview:cell];
    item.clipsToBounds = YES;
    [self.items addObject:item];
    [contentView addSubview:item];
    
    [self placeItem:item :shortestIndex :top :left];
    
}

- (void) layoutCells {
    
    [self initialize];
    
    for (UIView *item in self.items) {
        [self repositionItem:item];
    }
    
    // scroll to the last visible item
    if (lastVisibleItemIndex !=0) {
        UIView *lastVisibleItem = [self.items objectAtIndex:lastVisibleItemIndex];
        if (self.horizontalModeEnabled)
            [self setContentOffset:CGPointMake(lastVisibleItem.frame.origin.x, 0) animated:NO];
        else
            [self setContentOffset:CGPointMake(0, lastVisibleItem.frame.origin.y) animated:NO];
    }
    
    [self setContentSizeAuto];
    
    // position the spinner
    if ([self.items count] > 0 && self.loadMoreEnabled == YES) {
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
            spinner.alpha = 1;
            if (self.horizontalModeEnabled) {
                [spinner setFrame:CGRectMake(self.contentSize.width-20, self.bounds.size.height/2 - 20, 20, 20)];
                [spinnerLabel setFrame:CGRectMake(spinner.frame.origin.x + 50, self.bounds.size.height/2 - 20, spinnerLabel.frame.size.width, spinnerLabel.frame.size.height)];
            }
            else {
                [spinner setFrame:CGRectMake(self.bounds.size.width/2 - 20, self.contentSize.height-20, 20, 20)];
                [spinnerLabel setFrame:CGRectMake(self.bounds.size.width/2 - 100, spinner.frame.origin.y + 50, spinnerLabel.frame.size.width, spinnerLabel.frame.size.height)];
            }
        }
        completion:nil];
    }
}

- (void) clearCells {
    
    for (UIView *view in self.items) {
        [view removeFromSuperview];
    }
    
    self.items = nil;
    self.items = [NSMutableArray array];
    lastVisibleItemIndex = 0;
    
    [self initialize];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.loadMoreEnabled == YES) {
        
        BOOL isReady = NO;
        
        // make a visible item check, every 10 pixels scrolled
        // and make the spinner fill itself rotating    
        if(self.horizontalModeEnabled){       
            if ((int)scrollView.contentOffset.y % 10 == 0) {
                for (UIView *item in self.items) {
                    if (scrollView.contentOffset.y > item.frame.origin.y) {
                        lastVisibleItemIndex = [self.items indexOfObject:item];
                    }
                }
            }
            
            if (scrollView.contentOffset.x + scrollView.frame.size.width > scrollView.contentSize.width) {        
                float diff = scrollView.contentOffset.x + scrollView.frame.size.width - scrollView.contentSize.width;
                if (diff <= 100.0){
                    spinner.progress = diff-1;
                }
            }
            
            if ((scrollView.contentOffset.x + scrollView.frame.size.width > scrollView.contentSize.width + 100))
                isReady = YES;
        }
        else {
            if ((int)scrollView.contentOffset.x % 10 == 0) {
                for (UIView *item in self.items) {
                    if (scrollView.contentOffset.x > item.frame.origin.x) {
                        lastVisibleItemIndex = [self.items indexOfObject:item];
                    }
                }
            }            
            
            if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {        
                float diff = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
                if (diff <= 100.0){
                    spinner.progress = diff-1;
                }
            }
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 100))
                isReady = YES;
        }
        
        // handle the loading action when released
        if (isReady) {
            if (self.loading == NO) {
                readyToLoadWhenReleased = YES;
                [UIView beginAnimations:@"FadeAnimations" context:nil];
                [UIView setAnimationDuration:0.2f]; 
                spinnerLabel.alpha = 1;
                [UIView commitAnimations];            
            }
        }
        else {
            readyToLoadWhenReleased = NO;
            [UIView beginAnimations:@"FadeAnimations" context:nil];
            [UIView setAnimationDuration:0.2f]; 
            spinnerLabel.alpha = 0;
            [UIView commitAnimations];
        }
    }
    
    // also notify the delegate's method
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.loadMoreEnabled == NO) {
        return;
    }
    
    // start loading when dragging is released
    if (readyToLoadWhenReleased == YES && self.loading == NO) {
        [self.delegate didEnterLoadingMode];
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
            if (self.horizontalModeEnabled) {
                [self setContentSize:CGSizeMake(self.contentSize.width + 40, 0)];
            }
            else {
                [self setContentSize:CGSizeMake(0, self.contentSize.height + 40)];
            }
        }
        completion:nil];
    }  
}


@end
