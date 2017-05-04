//
//  DataManager+Tags.m
//  Votr
//
//  Created by Edward Kim on 1/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+Tags.h"
#import "VTRTag.h"

@implementation DataManager (Tags)

- (FIRDatabaseReference*)newTagReference
{
	FIRDatabaseReference *tags = [self.refDatabase child:@"tags"];
	return [tags childByAutoId];
}

- (FIRDatabaseReference*)pushTag:(VTRTag*)tag reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref))_onCompletion
{
	if (databaseRef == nil) {
		databaseRef = [self newTagReference];
	}
	[tag setKey:databaseRef.key];
	[databaseRef updateChildValues:[tag dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		_onCompletion(error,ref);
	}];
	
	return databaseRef;
}

- (NSDictionary*)pushTagStrings:(NSArray*)tagStrings reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref))_onCompletion
{
	
	//Todo Query all tags
	//If tag doesn't exit, create it
	//If tag does exist add postRefKey to tag
	NSMutableDictionary *tagKeys = [NSMutableDictionary new];
	
	for (NSString *tagString in tagStrings) {
		BOOL found = NO;
		for (VTRTag *tag in self.tags) {
			if ([tag.title caseInsensitiveCompare:tagString]==NSOrderedSame) {
				NSMutableDictionary *dict = [tag.posts mutableCopy];
				[dict setValue:@YES forKey:databaseRef.key];
				[tagKeys setValue:@YES forKey:tag.key];
				//Figure out hot to pass ref for tag so it doesn't create new tag
				tag.posts = dict;
				[self pushTag:tag reference:[[self.refDatabase child:@"tags"] child:tag.key] completion:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
					_onCompletion(error,ref);
				}];
				found = YES;
			}
		}
		
		if (!found) {
			//create newTag
			VTRTag *tag = [VTRTag new];
			[tag setTitle:tagString];
			if (databaseRef) {
				[tag setPosts:@{databaseRef.key:@YES}];
			}
			
			[tagKeys setValue:@YES forKey:[[self pushTag:tag reference:nil completion:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
				_onCompletion(error,ref);
			}] key]];
		}
	}

	
	return tagKeys;
}

- (void)searchTags:(NSString*)tag completion:(void(^)(NSArray * _Nonnull tags))_onCompletion
{
	FIRDatabaseQuery *query = [self.refDatabase child:@"tags"];
	[query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if(_onCompletion){
			NSMutableArray *marray = [NSMutableArray new];
			for (NSString *key in [snapshot.value allKeys] ) {
				NSDictionary *dict = snapshot.value[key];
				if (!([dict[@"title"] rangeOfString:tag options:NSCaseInsensitiveSearch].location==NSNotFound)) {
					[marray addObject:[VTRTag instanceFromDictionary:dict]];
				}
			}
			_onCompletion(marray);
		}
	}];
	//	[[[ref queryOrderedByChild:@"Email"]queryEqualToValue:@"test@gmail.com" ]
	//	 observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
	//		 NSLog(@"%@ Key %@ Value", snapshot.key,snapshot.value);
	//	 }];
}


@end
