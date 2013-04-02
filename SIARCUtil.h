//
//  SIARCUtil.h
//  SIKit
//
//  Created by Matias Pequeno on 2013/04/02.
//  Copyright (c) 2013 Silicon Illusions, Inc. All rights reserved.
//

#ifndef _SIARCUTIL_H_
#define _SIARCUTIL_H_

#ifndef arc_retain
#   if __has_feature(objc_arc)
#       define arc_retain self  // retain is still valid under arc in @property declarations
#       define arc_dealloc self // dealloc is a method name which cannot be redefined
#       define release self
#       define autorelease self
#   else
#       define arc_retain retain
#       define arc_dealloc dealloc
#       define __bridge
#   endif
#endif

//  Weak reference support
#import <Availability.h>
#if (!__has_feature(objc_arc)) || \
    (defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
    __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0) || \
    (defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
    __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_7)
#       undef weak
#       define weak unsafe_unretained
#       undef __weak
#       define __weak __unsafe_unretained
#endif

//  Weak delegate support
#ifndef ah_weak
#import <Availability.h>
#if (__has_feature(objc_arc)) && \
    ((defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
    __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || \
    (defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
    __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
#       define arc_weak weak
#       define __arc_weak __weak
#   else
#       define arc_weak unsafe_unretained
#       define __arc_weak __unsafe_unretained
#   endif
#endif

#endif // _ARCHELPER_H_
