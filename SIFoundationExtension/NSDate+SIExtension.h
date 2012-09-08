//
//  NSDate+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 10/5/12.
//  Copyright 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SIExtension)

- (NSString *)localizedTimeAgoStringSinceDate:(NSDate *)fromDate;

@end
