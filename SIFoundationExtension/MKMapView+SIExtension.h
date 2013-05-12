//
//  MKMapView+SIExtension.h
//  CanvassMate
//
//  Created by Matias Pequeno on 3/27/13.
//  Copyright (c) 2013 CanvassMate LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (SIExtension)

- (int)removeAllAnnotations;
- (int)removeAllOverlays;

@end
