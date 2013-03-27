//
//  MKMapView+SIExtension.m
//  CanvassMate
//
//  Created by Matias Pequeno on 3/27/13.
//  Copyright (c) 2013 CanvassMate LLC. All rights reserved.
//

#import "MKMapView+SIExtension.h"

@implementation MKMapView (SIExtension)

- (int)removeAllAnnotations
{
    NSArray *removalArray = [self.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]]];
    [self removeAnnotations:removalArray];
    LogDebug(@"Removed %d annotations from MKMapView (%p)", [removalArray count], self);
    return [removalArray count];
}

- (int)removeAllOverlays
{
    NSArray *removalArray = [NSArray arrayWithArray:self.overlays];
    [self removeOverlays:removalArray];
    LogDebug(@"Removed %d overlays from MKMapView (%p)", [removalArray count], self);
    return [removalArray count];
}

@end
