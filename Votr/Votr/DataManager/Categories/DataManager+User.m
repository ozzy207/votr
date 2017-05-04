//
//  DataManager+User.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+User.h"
#import "VTRUser.h"
#import "VTRPost.h"
#import "VTRComment.h"	

@implementation DataManager (User)

- (void)updateUser:(VTRUser*)user onCompletion:(void(^)(NSError *error, FIRDatabaseReference  *_Nonnull ref))_onCompletion
{
	FIRDatabaseReference *ref = [[self.refDatabase child:@"users"] child:user.key];
	[ref updateChildValues:[user dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if(_onCompletion){
			_onCompletion(error,ref);
		}
	}];
}

- (void)searchUsers:(NSString*)userName completion:(void(^)(NSArray * _Nonnull users))_onCompletion
{
	FIRDatabaseQuery *query = [self.refDatabase child:@"users"];
	[query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if(_onCompletion){
			NSMutableArray *marray = [NSMutableArray new];
			for (NSString *key in [snapshot.value allKeys] ) {
				NSDictionary *dict = snapshot.value[key];
				if (!([dict[@"displayName"] rangeOfString:userName options:NSCaseInsensitiveSearch].location==NSNotFound)) {
					[marray addObject:[VTRUser instanceFromDictionary:dict]];
				}
			}
			_onCompletion(marray);
		}
	}];
}

- (void)getUser:(NSString*)userID completion:(void(^)(VTRUser *user))_onCompletion
{
	FIRDatabaseQuery *query = [[self.refDatabase child:@"users"] child:userID];
	
	[query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if(_onCompletion){

			_onCompletion([VTRUser instanceFromDictionary:snapshot.value]);
		}
	}];
}

- (void)followUser:(NSString*)userID
{
	
}
@end
