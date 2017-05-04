//
//  VTRPoll.m
//  Votr
//
//  Created by Edward Kim on 1/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRPost.h"
#import "VTRVote.h"
#import "VTRComment.h"
#import "VTRPostItem.h"

@implementation VTRPost

- (instancetype)init
{
	if (self = [super init]) {
		_creationDate = [NSDate date];
	}
	return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"creationDate"]) {
		self.creationDate = [self dateFromString:value];
		return;
	}
	
	if ([key isEqualToString:@"startDate"]) {
		self.startDate = [self dateFromString:value];
		return;
	}
	
	if ([key isEqualToString:@"endDate"]) {
		self.endDate = [self dateFromString:value];
		return;
	}
	
//	if([key isEqualToString:@"votes"]){
//		NSMutableDictionary *mdict = [NSMutableDictionary new];
//		for (NSString *key in [value allKeys]) {
//			[mdict setValue:[VTRVote instanceFromDictionary:value[key]] forKey:key];
//		}
//		self.votes = mdict;
//		return;
//	}
//	
	if([key isEqualToString:@"items"]){
		NSMutableArray *marray = [NSMutableArray new];
		for (NSDictionary *dict in value) {
			[marray addObject:[VTRPostItem instanceFromDictionary:dict]];
		}
		self.items = marray;
		return;
	}
	
	if([key isEqualToString:@"comments"]){
		NSMutableDictionary *mdict = [NSMutableDictionary new];
		for (NSString *key in [value allKeys]) {
			[mdict setValue:[VTRComment instanceFromDictionary:value[key]] forKey:key];
		}
		self.comments = mdict;
		return;
	}
	
	[super setValue:value forKey:key];
}

- (NSMutableDictionary*)allowedUsers
{
	if (_allowedUsers == nil) {
		_allowedUsers = [NSMutableDictionary new];
	}
	return _allowedUsers;
}



- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [super dictionaryRepresentation];
	
	if (self.isPrivate) {
		[mDictionary setObject:@(self.isPrivate) forKey:@"isPrivate"];
	}
	
	if (self.owner){
		[mDictionary setObject:self.owner forKey:@"owner"];
	}
	
	if (self.items){
		//[mDictionary setObject:self.items forKey:@"items"];
		NSMutableArray *marray = [NSMutableArray new];
		for (VTRPostItem *obj in self.items) {
			[marray addObject:[obj dictionaryRepresentation]];
		}
		[mDictionary setObject:marray forKey:@"items"];
	}
	
	if (self.allowedUsers) {
		[mDictionary setObject:self.allowedUsers forKey:@"allowedUsers"];
	}
	
	if (self.creationDate) {
		[mDictionary setObject:[self stringFromDate:self.creationDate] forKey:@"creationDate"];
	}
	
	if (self.startDate) {
		[mDictionary setObject:[self stringFromDate:self.startDate] forKey:@"startDate"];
	}
	
	if (self.endDate) {
		[mDictionary setObject:[self stringFromDate:self.endDate] forKey:@"endDate"];
	}
	
	if (self.tags) {
		[mDictionary setObject:self.tags forKey:@"tags"];
	}
	
	if (self.messageKey){
		[mDictionary setObject:self.messageKey forKey:@"messageKey"];
	}
	
	if (self.votes){
		[mDictionary setObject:self.votes forKey:@"votes"];
//		NSMutableDictionary *mdict = [NSMutableDictionary new];
//		for (NSString *key in [self.votes allKeys]) {
//			[mdict setValue:[self.votes[key] dictionaryRepresentation] forKey:key];
//		}
//		
//		[mDictionary setObject:mdict forKey:@"votes"];
	}
	
	if (self.comments){
		NSMutableDictionary *mdict = [NSMutableDictionary new];
		for (NSString *key in [self.comments allKeys]) {
			[mdict setValue:[self.comments[key] dictionaryRepresentation] forKey:key];
		}

		[mDictionary setObject:mdict forKey:@"comments"];
	}
	return mDictionary;
}

@end
