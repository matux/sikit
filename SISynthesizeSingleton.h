//
//  SISynthesizeSingleton.h
//  SIKit
//
//  Created by Matias Pequeno on 2011/08/23.
//  Copyright (c) 2011 Silicon Illusions, Inc. All rights reserved.
//

#import <objc/runtime.h>

#define SI_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName) \
+ (classname *)accessorMethodName;

#if __has_feature(objc_arc)
	#define SI_SYNTHESIZE_SINGLETON_RETAIN_METHODS
#else
	#define SI_SYNTHESIZE_SINGLETON_RETAIN_METHODS \
	- (id)retain \
	{ \
		return self; \
	} \
	 \
	- (NSUInteger)retainCount \
	{ \
		return NSUIntegerMax; \
	} \
	 \
	- (oneway void)release \
	{ \
	} \
	 \
	- (id)autorelease \
	{ \
		return self; \
	}
#endif

#define SI_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName) \
 \
static classname *accessorMethodName##Instance = nil; \
 \
+ (classname *)accessorMethodName \
{ \
	@synchronized(self) \
	{ \
		if (accessorMethodName##Instance == nil) \
		{ \
			accessorMethodName##Instance = [super allocWithZone:NULL]; \
			accessorMethodName##Instance = [accessorMethodName##Instance init]; \
			method_exchangeImplementations(\
				class_getClassMethod([accessorMethodName##Instance class], @selector(accessorMethodName)),\
				class_getClassMethod([accessorMethodName##Instance class], @selector(si_lockless_##accessorMethodName)));\
			method_exchangeImplementations(\
				class_getInstanceMethod([accessorMethodName##Instance class], @selector(init)),\
				class_getInstanceMethod([accessorMethodName##Instance class], @selector(si_onlyInitOnce)));\
		} \
	} \
	 \
	return accessorMethodName##Instance; \
} \
 \
+ (classname *)si_lockless_##accessorMethodName \
{ \
	return accessorMethodName##Instance; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
	return [self accessorMethodName]; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
- (id)si_onlyInitOnce \
{ \
	return self;\
} \
 \
SI_SYNTHESIZE_SINGLETON_RETAIN_METHODS

#define SI_DECLARE_SINGLETON_FOR_CLASS(classname) SI_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared##classname)
#define SI_SYNTHESIZE_SINGLETON_FOR_CLASS(classname) SI_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared##classname)
