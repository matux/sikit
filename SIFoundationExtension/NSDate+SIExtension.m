//
//  NSDate+SIExtension.m
//  SIKit
//
//  Created by Matias Pequeno on 10/5/12.
//  Copyright 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "NSDate+SIExtension.h"

@implementation NSDate (SIExtension)

- (NSString *)localizedTimeAgoStringSinceDate:(NSDate *)sinceDate
{
    const int kSecond = 1;
    const int kMinute = 60 * kSecond;
    const int kHour = 60 * kMinute;
    const int kDay = 24 * kHour;
    const int kMonth = 30 * kDay;
    const int kYear = 12 * kMonth;

    double delta = [sinceDate timeIntervalSinceDate:self];

    if (delta < 1 * kMinute) {
        return NSLocalizedStringFromTable(@"Less_Than_A_Minute_Ago", @"SIKitLocalizable", @"less than a minute ago");
    }

    if (delta < 2 * kMinute) {
        return NSLocalizedStringFromTable(@"One_Minute_Ago", @"SIKitLocalizable", @"1 minute ago");
    }

    if (delta < kHour) {
        int diff = (int) round(delta / kMinute);
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d_Minutes_Ago", @"SIKitLocalizable", @"%d minutes ago"), diff];
    }
    
    if (delta < kDay) {
        int diff = (int)round(delta / kHour);
        return (diff <= 1 ? (NSLocalizedStringFromTable(@"One_Hour_Ago", @"SIKitLocalizable", @"One_Hour_Ago")) :
                            ([NSString stringWithFormat:NSLocalizedStringFromTable(@"%d_Hours_Ago", @"SIKitLocalizable", @"%d hours ago"), diff]) );
    }

    if (delta < 48 * kHour) {
        return NSLocalizedStringFromTable(@"Yesterday", @"SIKitLocalizable", @"yesterday");
    }

    if (delta < kMonth) {
        int diff = (int) round(delta / kDay);
        return (diff <= 1 ? (NSLocalizedStringFromTable(@"One_Month_Ago", @"SIKitLocalizable", @"One_Month_Ago")) :
                             ([NSString stringWithFormat:NSLocalizedStringFromTable(@"%d_Days_Ago", @"SIKitLocalizable", @"%d days ago"), diff]));
    }

    if (delta < kYear) {
        int diff = (int) round(delta / kMonth);
        return (diff <= 1 ? (NSLocalizedStringFromTable(@"One_Month_Ago", @"SIKitLocalizable", @"one month ago")) :
                            ([NSString stringWithFormat:NSLocalizedStringFromTable(@"%d_Months_Ago", @"SIKitLocalizable", @"%d months ago"), diff]));
    }

    int diff = (int) round(delta / kYear);
    return diff <= 1 ? NSLocalizedStringFromTable(@"One_Year_Ago", @"SIKitLocalizable", @"one year ago") : [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d_Years_Ago", @"SIKitLocalizable", @"%d years ago"), diff];
}

@end
