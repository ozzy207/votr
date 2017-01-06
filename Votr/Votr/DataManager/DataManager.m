//
//  DataManager.m
//  Votr
//
//  Created by Edward Kim on 1/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
@import Firebase;

@interface DataManager ()
@property (strong, nonatomic) FIRStorage *storage;
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
		[_sharedObject setStorage:[FIRStorage storage]];
	});
	
	// returns the same object each time
	return _sharedObject;
}
@end
