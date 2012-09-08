//
//  NSBundle+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 8/22/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (SIExtension)

@end

#define SILocalizedString(key) \
        [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]
