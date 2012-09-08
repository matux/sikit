//
//  SIAppStoreUtil.m
//  SIKit
//
//  Created by Matias Pequeno on 7/18/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import "SIAppStoreUtil.h"
#import "SIUtil.h"

#define kRatedVersionKey    @"SIRatedVersionChecked"
#define kDeclinedVersionKey @"SIDeclinedVersion"
#define kLastRemindedKey    @"SILastReminded"
#define kLastVersionUsedKey @"SILastVersionUsed"
#define kLastBuildUsedKey   @"SILastBuildUsed"
#define kIsLatestVerUsedKey @"SIIsLatestVersion"
#define kExecCountKey       @"SIExecCount"
#define kExecCountToRateKey @"SIExecCountToRate"

#define kAppStoreBundleID   @"com.apple.appstore"
#define kAppLookupURLFormat @"http://itunes.apple.com/lookup?country=%@&bundleId=%@"

#define kAppStoreURLFormat  @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&onlyLatestVersion=true&id=%u"

#define kAutomateExecutionTimeCount     false
#define kForceDefaultReset              false

@implementation SIAppStoreUtil

@synthesize delegate = _delegate;

@synthesize appStoreID = _appStoreID;
@synthesize appStoreCountry = _appStoreCountry;
@synthesize applicationName = _applicationName;
@synthesize applicationVersion = _applicationVersion;
@synthesize applicationBuildNumber = _applicationBuildNumber;
@synthesize applicationBundleID = _applicationBundleID;

@synthesize declinedToRateThisVersion = _declinedToRateThisVersion;
@synthesize ratedThisVersion = _ratedThisVersion;
@synthesize isLatestVersion = _isLatestVersion;
@synthesize lastTimeReminded = _lastTimeReminded;
@synthesize executionCount = _executionCount;
@synthesize executionCountBeforePromptingForRating = _executionCountBeforePromptingForRating;

#pragma mark -
#pragma mark init

+ (SIAppStoreUtil *)appStoreUtil
{
    static dispatch_once_t predicate = 0;
    __strong static SIAppStoreUtil *_appStoreUtil = nil;
    
    dispatch_once(&predicate, ^{
        _appStoreUtil = [[self alloc] init];
    });
    
    return _appStoreUtil;
    
}

- (id)init
{
    if( self = [super init] )
    {
        // Initialize
        self.appStoreCountry = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        self.applicationBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        self.applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        // If this is a new version, we have to reset the notification
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *lastVersionUsed = [userDefaults objectForKey:kLastVersionUsedKey];
        NSString *lastBuildUsed = [userDefaults objectForKey:kLastBuildUsedKey];
        if (![lastVersionUsed isEqualToString:self.applicationVersion] ||
            ![lastBuildUsed isEqualToString:self.applicationBuildNumber] ||
            kForceDefaultReset )
        {
            // Reset stored defaults
            [userDefaults setObject:self.applicationVersion forKey:kLastVersionUsedKey];
            [userDefaults setObject:self.applicationBuildNumber forKey:kLastBuildUsedKey];
            [userDefaults setInteger:0 forKey:kExecCountKey];
            [userDefaults setInteger:0 forKey:kExecCountToRateKey];
            [userDefaults setObject:nil forKey:kRatedVersionKey];
            [userDefaults setObject:nil forKey:kDeclinedVersionKey];
            [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kIsLatestVerUsedKey];
            [userDefaults setObject:nil forKey:kLastRemindedKey];
            [userDefaults synchronize];
        }
        
        // Execution count is handled manually for now.
        if( kAutomateExecutionTimeCount )
            [self setExecutionCount:self.executionCount + 1];

    }
    
    return self;
}

- (void)dealloc
{
    [_appStoreCountry release];
    [_applicationBundleID release];
    [_applicationName release];
    [_applicationVersion release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark App Store Actions

- (BOOL)shouldPromptForRating
{
    BOOL challenge = ((!(self.ratedThisVersion || self.declinedToRateThisVersion)) &&
                      self.isLatestVersion &&
                      self.executionCount >= self.executionCountBeforePromptingForRating);
    
    return challenge;
}

- (BOOL)openRatingsPage
{
    if (self.appStoreID <= 0) {
        [self retrieveAppTrackID];
    }
    
    if (self.appStoreID) { 
        
        NSString *ratingURLString = [NSString stringWithFormat:kAppStoreURLFormat, (unsigned int)self.appStoreID];
        NSURL *ratingURL = [NSURL URLWithString:ratingURLString];
        LogAppStore(@"Opening URL %@", ratingURL);
        if( [[UIApplication sharedApplication] canOpenURL:ratingURL] ) 
        {
            [self setRatedThisVersion:YES];
            [self setDeclinedThisVersion:NO];
            [[UIApplication sharedApplication] openURL:ratingURL];
        } 
        else 
            [self setAppStoreID:0];
        
    }
    
    return (BOOL)self.appStoreID;
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n \
            ******************************\n \
            * SIAppStoreUtil description *\n \
            ******************************\n \
            appStoreID: %d\n \
            appStoreCountry: %@\n \
            applicationName: %@\n \
            applicationVersion: %@\n \
            applicationBuildNumber: %@\n \
            applicationBundleID: %@\n \
            ----\n \
            declinedToRateThisVersion: %@\n \
            ratedThisVersion: %@\n \
            isLatestVersion: %@\n \
            lastTimeReminded: %@\n \
            executionCount: %d\n \
            executionCountBeforePromptingForRating: %d\n \
            ----\n \
            shouldPromptForRating: %@",
            self.appStoreID, self.appStoreCountry, self.applicationName, self.applicationVersion, self.applicationBuildNumber,
            self.applicationBundleID, self.declinedToRateThisVersion?@"YES":@"NO", self.ratedThisVersion?@"YES":@"NO",
            self.isLatestVersion?@"YES":@"NO", self.lastTimeReminded, self.executionCount, self.executionCountBeforePromptingForRating, 
            [self shouldPromptForRating]?@"YES":@"NO"];
            
}

#pragma mark -
#pragma mark Private methods

- (void)retrieveAppTrackID
{
    if( [_delegate respondsToSelector:@selector(willSyncWithItunesConnect)] )
        [_delegate willSyncWithItunesConnect];
    
    // Set proper iTunes URL
    NSString *iTunesServiceURL = [NSString stringWithFormat:kAppLookupURLFormat, self.appStoreCountry, self.applicationBundleID];
    
    LogAppStore(@"Connecting to iTunes Service at: %@", iTunesServiceURL);
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunesServiceURL] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if( data )
    {
        // Get the JSON string
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        LogAppStore(@"iTunes Service - Got response with %d bytes", [data length]);
        //LogQuiet(@"%@", json);
        
        // Track ID
        NSString *appStoreIDString = SIValueInJsonForKey(json, @"trackId");
        self.appStoreID = (NSUInteger)[appStoreIDString longLongValue];
        LogAppStore(@"iTunes Service - Got appStoreID: %d", self.appStoreID);
        
        // Check version (we only want to rate if this is the latest version)
        NSString *latestVersion = SIValueInJsonForKey(json, @"version");
        [self setIsLatestVersion:!([latestVersion compare:self.applicationVersion options:NSNumericSearch] == NSOrderedDescending)];
    }
    
    if( [_delegate respondsToSelector:@selector(didFinishSyncWithItunesConnect)] )
        [_delegate didFinishSyncWithItunesConnect];
    
}

#pragma mark -
#pragma mark Custom Getter and Setters

- (NSDate *)lastTimeReminded
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastRemindedKey];
}

- (void)setLastTimeReminded:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastRemindedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)executionCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kExecCountKey];
}

- (void)setExecutionCount:(NSUInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:kExecCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)incrementExecutionCount
{
    [self setExecutionCount:self.executionCount + 1];
    
    LogAppStore(@"Incremented execution time to: %d - shouldPromptForRating: %@", 
                (int)self.executionCount, ([self shouldPromptForRating]?@"YES":@"NO"));
    
    LogAppStore(@"Challenge Details: (_ratedThisVersion:%@_declinedToRateThisVersion:%@_isLatestVersion:%@)",
                (self.ratedThisVersion?@"YES":@"NO"), (self.declinedToRateThisVersion?@"YES":@"NO"), (self.isLatestVersion?@"YES":@"NO"));
    
    if( [self shouldPromptForRating] && [_delegate respondsToSelector:@selector(applicationShouldPromptForRating)] )
         [_delegate applicationShouldPromptForRating];
         
    return [self shouldPromptForRating];
}

- (NSUInteger)executionCountBeforePromptingForRating
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kExecCountToRateKey];
}

- (void)setExecutionCountBeforePromptingForRating:(NSUInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:kExecCountToRateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isLatestVersion
{
    return [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kIsLatestVerUsedKey] boolValue];
}

- (void)setIsLatestVersion:(BOOL)isLatestVersion
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isLatestVersion] forKey:kIsLatestVerUsedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)declinedThisVersion
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kDeclinedVersionKey] isEqualToString:self.applicationVersion];
}

- (void)setDeclinedThisVersion:(BOOL)declined
{
    [[NSUserDefaults standardUserDefaults] setObject:(declined ? self.applicationVersion : nil) 
                                              forKey:kDeclinedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)ratedThisVersion
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kRatedVersionKey] isEqualToString:self.applicationVersion];
}

- (void)setRatedThisVersion:(BOOL)rated
{
    [[NSUserDefaults standardUserDefaults] setObject:(rated ? self.applicationVersion : nil) 
                                              forKey:kRatedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
