//
//  NSUserDefaults+SIExtension.m
//  weheartit
//
//  Created by Matias Pequeno on 9/25/12.
//  Copyright (c) 2012 Silicon Illusions Inc. All rights reserved.
//

#import "NSUserDefaults+SIExtension.h"

@implementation NSUserDefaults (SIExtension)

+ (void)registerDefaultsFromSettingsBundle
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if( !settingsBundle ) {
        LogError(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[[NSMutableDictionary alloc] initWithCapacity:[preferences count]] autorelease];
    for( NSDictionary *prefSpecification in preferences )
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id defaultValue = [prefSpecification objectForKey:@"DefaultValue"];
        if( key && defaultValue )
            [defaultsToRegister setObject:defaultValue forKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
