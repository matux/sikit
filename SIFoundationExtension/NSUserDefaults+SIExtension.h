//
//  NSUserDefaults+SIExtension.h
//  weheartit
//
//  Created by Matias Pequeno on 9/25/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (SIExtension)

+ (void)registerDefaultsFromSettingsBundle; /*! @note this does not support child panes */

@end
