//
//  SIMessageInterceptor.h
//  SIKit
//
//  Created by Matias Pequeno on 9/15/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIMessageInterceptor : NSObject

@property (nonatomic, readwrite, unsafe_unretained) id receiver;
@property (nonatomic, readwrite, unsafe_unretained) id middleMan;

@end
