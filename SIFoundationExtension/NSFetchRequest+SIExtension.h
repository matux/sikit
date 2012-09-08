//
//  NSFetchRequest+Extension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/26/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

/*!
 @category NSFetchRequest (SIExtension)
 */
@interface NSFetchRequest (SIExtension)

+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription;
+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription andPredicate:(NSPredicate *)predicate;
+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription andPredicate:(NSPredicate *)predicate andSortDescriptor:(NSSortDescriptor *)sortDescriptor;
+ (NSFetchRequest *)fetchRequestWithEntity:(NSEntityDescription *)entityDescription andPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescriptors;

@end
