//
//  NSFetchRequest+Extension.m
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "NSFetchRequest+SIExtension.h"

@implementation NSFetchRequest (SIExtension)

+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	return fetchRequest;
}

+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription andPredicate:(NSPredicate *)predicate
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	[fetchRequest setPredicate:predicate];
	return fetchRequest;
}
	 
+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription andPredicate:(NSPredicate *)predicate andSortDescriptor:(NSSortDescriptor *)sortDescriptor
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];
	return fetchRequest;
}

+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription andPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescriptors
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:sortDescriptors];
	return fetchRequest;
}

@end
