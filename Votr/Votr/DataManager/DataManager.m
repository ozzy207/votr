//
//  DataManager.m
//  Votr
//
//  Created by Edward Kim on 1/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@end

@implementation DataManager

+ (instancetype)sharedInstance
{
	// structure used to test whether the block has completed or not
	static dispatch_once_t p = 0;
	
	// initialize sharedObject as nil (first call only)
	__strong static id _sharedObject = nil;
	
	// executes a block object once and only once for the lifetime of an application
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
		[_sharedObject setRefStorage:[FIRStorage storage].reference];
		[_sharedObject setRefDatabase:[FIRDatabase database].reference];
		[_sharedObject initializeTopics];
	});
	
	// returns the same object each time
	return _sharedObject;
}

- (void)initializeTopics
{
//	NSArray *topicsArray = @[@"Animals",@"Art",@"Celebrity",@"Entertainment",@"Fashion",@"Finance",@"Food",@"Funny",@"Health",@"LifeyStyle",@"News",@"Photography",@"Politics",@"Science",@"Sports",@"Travel"];
//	FIRDatabaseReference *topics = [self.refDatabase child:@"topics"];
//	//[topics setValue:topicsArray];
//	for (NSString *title in topicsArray) {
//		FIRDatabaseReference *topic = [topics childByAutoId];
//		[topic setValue:@{@"title":title}];
//	}

	//[self queryTopics:@"New"];
}

- (void)queryTopics:(NSString*)string
{
	FIRDatabaseReference *topics = [self.refDatabase child:@"topics"];
//	FIRDatabaseQuery *query = [topics queryOrderedByChild:@"title"];
//	[query queryStartingAtValue:String];
	[topics observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		NSLog(@"%@",snapshot);
		//NSMutableArray *marray = [snapshot.value mutableCopy];
		NSMutableDictionary *titles = [snapshot.value mutableCopy];
		//titles al
//		titles = [titles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY SELF contains[c] %@",string]];
//		[titles filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//			return [evaluatedObject[@"title"] containsString:string];
//		}]];
//		[marray filterUsingPredicate:[NSPredicate predicateWithFormat:@"ANY title like %@",string]];
		NSLog(@"%@",titles);
	}];
	
}
@end
