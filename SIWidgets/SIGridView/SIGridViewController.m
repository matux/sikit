//
//  SIGridViewController.m
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIGridViewController.h"

@implementation SIGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get the screenWidth to determine the resolution
    _screenWidth = (int)[[UIScreen mainScreen] applicationFrame].size.width % 256;

    // create a MasonryView in any size you want
    _gridView = [[SIGridView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

    // set delegate to self
    _gridView.delegate = self;

    // set a size for each column, 256px wide columns means 4 columns for landscape and 3 for portrait (4*246=1024, 3*256=768)
    // set column width to 256px if the view is in iPad
    if( (int)[[UIScreen mainScreen] applicationFrame].size.width % 256 == 0 )
    {
        _gridView.columnWidth = 256;
        
        // if you are going to use the horizontal mode, set a row height otherwise, this is not necessary
        _gridView.rowHeight = 230;
    }
    else
    {
        // if iPhone, set it to 160px
        _gridView.columnWidth = 160;
        _gridView.rowHeight = 130;
    }

    // enable paging
    _gridView.loadMoreEnabled = YES;
    
    // optional
    _gridView.backgroundColor = [UIColor darkGrayColor];
    
    // optional
    _gridView.horizontalModeEnabled = NO;
    
    // add it to your default view
    [self.view addSubview:_gridView];

    // start fetching data from a remote API
    [self fetchData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // reorder items when there is an orientation change
    [_gridView layoutCells];
}

#pragma mark
#pragma mark SIGridViewDelegate implementation

- (void)gridViewDidEnterLoadingMode:(SIGridView *)gridView
{
    // fetch data again if it is dragged and released in the bottom
    [self fetchData];
}

- (void)gridView:(SIGridView *)gridView didSelectItemAtIndex:(int)index
{
    
}

#pragma mark
#pragma mark SIGridViewDataSource implementation

- (void)fetchData
{
    // set your MasonryView to be in loading state
    _gridView.loading = YES;

}

- (void)clearItems
{
    [_gridView clearCells];
    [self fetchData];
}


@end
