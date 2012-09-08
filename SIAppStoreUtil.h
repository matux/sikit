//
//  SIAppStoreUtil.h
//  SIKit
//
//  Created by Matias Pequeno on 7/18/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SIAppStoreUtilDelegate <NSObject>
@optional
- (void)willSyncWithItunesConnect;
- (void)didFinishSyncWithItunesConnect;
- (void)applicationShouldPromptForRating;
@end

@interface SIAppStoreUtil : NSObject

// Delegate
@property (nonatomic, readwrite, unsafe_unretained) id <SIAppStoreUtilDelegate> delegate;

// App Store and Application properties
@property (nonatomic, readwrite, assign) NSInteger appStoreID;
@property (nonatomic, readwrite, copy) NSString *appStoreCountry;
@property (nonatomic, readwrite, copy) NSString *applicationName;
@property (nonatomic, readwrite, copy) NSString *applicationVersion;
@property (nonatomic, readwrite, copy) NSString *applicationBuildNumber;
@property (nonatomic, readwrite, copy) NSString *applicationBundleID;

// App Store Rating properties
@property (nonatomic, readwrite, assign) BOOL declinedToRateThisVersion;
@property (nonatomic, readwrite, assign) BOOL ratedThisVersion;
@property (nonatomic, readwrite, assign) BOOL isLatestVersion;
@property (nonatomic, readwrite, strong) NSDate *lastTimeReminded;
@property (nonatomic, readwrite, assign) NSUInteger executionCount;
@property (nonatomic, readwrite, assign) NSUInteger executionCountBeforePromptingForRating;

// Unique instance
+ (SIAppStoreUtil *)appStoreUtil;

// Basic checking
- (BOOL)shouldPromptForRating; 

// Opens up App Store ratings page
- (BOOL)openRatingsPage;

// Increments execution time by one
// Returns whether or not a request for rating should be presented
- (BOOL)incrementExecutionCount;

@end
