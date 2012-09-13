//
//  NSArray+Extension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSArray (SIExtension)

- (BOOL)isEmpty;
- (NSDictionary *)indexKeyedDictionary;

- (id)firstObject;

@end
