//
//  NSUserDefaults+SIExtension.m
//  weheartit
//
//  Created by Matias Pequeno on 9/25/12.
//  Copyright (c) 2012 Silicon Illusions Inc. All rights reserved.
//

#import "NSUserDefaults+SIExtension.h"
#import "SILogging.h"

@implementation NSUserDefaults (SIExtension)

+ (void)registerDefaultsFromSettingsBundle
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if( !settingsBundle ) {
        LogWarning(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = settings[@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for( NSDictionary *prefSpecification in preferences )
    {
        NSString *key = prefSpecification[@"Key"];
        id defaultValue = prefSpecification[@"DefaultValue"];
        if( key && defaultValue )
            defaultsToRegister[key] = defaultValue;
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
