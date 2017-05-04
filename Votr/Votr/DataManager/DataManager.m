//
//  DataManager.m
//  Votr
//
//  Created by Edward Kim on 1/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
#import "VTRTag.h"
#import "UIImageView+WebCache.h"

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
		[_sharedObject initialize];
	});
	
	// returns the same object each time
	return _sharedObject;
}

- (instancetype)init
{
	if (self = [super init]) {
		_tasks = [NSMutableArray new];
		_snapshots = [NSMutableArray new];
		_tags = [NSMutableArray new];
		
	}
	return self;
}

- (void)initialize
{
//	NSArray *topicsArray = @[@"Animals",@"Art",@"Celebrity",@"Entertainment",@"Fashion",@"Finance",@"Food",@"Funny",@"Health",@"LifeyStyle",@"News",@"Photography",@"Politics",@"Science",@"Sports",@"Travel"];
//	FIRDatabaseReference *topics = [self.refDatabase child:@"topics"];
//	//[topics setValue:topicsArray];
//	for (NSString *title in topicsArray) {
//		FIRDatabaseReference *topic = [topics childByAutoId];
//		[topic setValue:@{@"title":title}];
//	}

	//[self queryTopics:@"New"];
	//[[SDImageCache sharedImageCache] setMaxCacheSize:10*1000];
	
	[[self.refDatabase child:@"tags"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		NSMutableArray *marray = [NSMutableArray new];
		if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
			for (NSString *key in [snapshot.value allKeys]) {
				NSDictionary *dict = [snapshot.value objectForKey:key];
				VTRTag *tag = [VTRTag instanceFromDictionary:dict];
				[tag setKey:key];
				[marray addObject:tag];
			}
			self.tags = marray;
		}

	} withCancelBlock:^(NSError * _Nonnull error) {
		NSLog(@"%@", error.localizedDescription);
	}];
	
	if ([FIRAuth auth].currentUser) {
		FIRDatabaseReference *usersRef = [self.refDatabase child:@"users"];
		[[usersRef child:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
			if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
				self.user = [VTRUser instanceFromDictionary:snapshot.value];
			}
		} withCancelBlock:^(NSError * _Nonnull error) {
			NSLog(@"%@", error.localizedDescription);
		}];
	}

}

- (VTRUser*)user
{
	if (_user == nil) {
		_user = [VTRUser new];
	}
	return _user;
}


@end
