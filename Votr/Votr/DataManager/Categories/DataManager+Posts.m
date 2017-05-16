//
//  DataManager+post.m
//  Votr
//
//  Created by Edward Kim on 1/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+Posts.h"
#import "VTRPost.h"
#import "VTRVote.h"

@implementation DataManager (Posts)

- (FIRDatabaseReference*)newPostReference
{
	FIRDatabaseReference *posts = [self.refDatabase child:@"posts"];
	return [posts childByAutoId];
}

- (FIRDatabaseReference*)newPostItemReference
{
	FIRDatabaseReference *postItems = [self.refDatabase child:@"postItems"];
	return [postItems childByAutoId];
}

- (FIRDatabaseReference*)pushPost:(VTRPost*)post reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref))_onCompletion
{
	if (databaseRef == nil) {
		databaseRef = [self newPostReference];
	}
	[post setKey:databaseRef.key];
	
	__weak typeof (self) weakSelf = self;
	[databaseRef updateChildValues:[post dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		//Update reference to users
		NSMutableDictionary *posts = weakSelf.user.posts;
		[posts setValue:@YES forKey:databaseRef.key];
		weakSelf.user.posts = posts;
		[[[[weakSelf.refDatabase child:@"users"] child:[FIRAuth auth].currentUser.uid] child:@"posts"] setValue:posts withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
			_onCompletion(error,ref);
		}];
		
	}];
	return databaseRef;
}


- (FIRDatabaseReference*)pushPostItem:(VTRPostItem*)postItem reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref))_onCompletion
{
	if (databaseRef == nil) {
		databaseRef = [self newPostReference];
	}
	[postItem setKey:databaseRef.key];

	[databaseRef updateChildValues:[postItem dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if(_onCompletion){
			_onCompletion(error,ref);
		}
	}];
	
	return databaseRef;
}

- (void)searchPostTitle:(NSString*)title completion:(void(^)(NSArray * _Nonnull posts))_onCompletion
{
	FIRDatabaseQuery *query = [self.refDatabase child:@"posts"];
	[query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if(_onCompletion){
			NSMutableArray *marray = [NSMutableArray new];
			for (NSString *key in [snapshot.value allKeys] ) {
				NSDictionary *dict = snapshot.value[key];
				if (title.length>0){
					if (!([dict[@"title"] rangeOfString:title options:NSCaseInsensitiveSearch].location==NSNotFound)) {
						[marray addObject:[VTRPost instanceFromDictionary:dict]];
					}
				}else{
					[marray addObject:[VTRPost instanceFromDictionary:dict]];
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


- (void)votePostKey:(NSString*)postKey postItemIndex:(NSInteger)selectedIndex completion:(void(^)(FIRDataSnapshot * _Nullable snapshot))_onCompletion
{
	__block NSInteger blkSelectedIndex = selectedIndex;
	__weak typeof (self)weakSelf = self;
	FIRDatabaseReference *ref = [[self.refDatabase child:@"posts"] child:postKey];
	[ref runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
		VTRPost *post = [VTRPost instanceFromDictionary:currentData.value];
		if (!post || [post isEqual:[NSNull null]]) {
			return [FIRTransactionResult successWithValue:currentData];
		}
		
		NSMutableDictionary *votes = [post.votes mutableCopy];
		if (!votes) {
			votes = [NSMutableDictionary new];
		}
		
		NSString *uid = [FIRAuth auth].currentUser.uid;
		NSMutableDictionary *postsVoted = [weakSelf.user.postsVoted mutableCopy];

		if (!postsVoted) {
			postsVoted = [NSMutableDictionary new];
		}
		
		if (postsVoted[postKey]) {
			[postsVoted removeObjectForKey:postKey];
			
			if (post.votes[uid]) {
				[votes removeObjectForKey:uid];
			}
		} else {
			[postsVoted setValue:@YES forKey:postKey];
			
			//VTRVote *vote = [VTRVote instanceFromDictionary:@{@"selectedIndex":@(blkSelectedIndex)}];
			//[votes setValue:vote.selectedIndex forKey:uid];
			[votes setValue:@(blkSelectedIndex) forKey:uid];
		}
		
		weakSelf.user.postsVoted = postsVoted;
		
		[[[weakSelf.refDatabase child:@"users"] child:[FIRAuth auth].currentUser.uid] updateChildValues:[weakSelf.user dictionaryRepresentation]];
		
		post.votes = votes;
		// Set value and report transaction success
		currentData.value = [post dictionaryRepresentation];
		return [FIRTransactionResult successWithValue:currentData];
	} andCompletionBlock:^(NSError * _Nullable error,
						   BOOL committed,
						   FIRDataSnapshot * _Nullable snapshot) {
		// Transaction completed
		if (error) {
			NSLog(@"%@", error.localizedDescription);
		}else{
			if(_onCompletion){
				_onCompletion(snapshot);
			}
		}
	}];
}

- (void)deletePost:(VTRPost*)post completion:(void(^)(NSError * _Nullable error,FIRDatabaseReference * _Nonnull ref))_onCompletion
{

	//delete post items
//	for (NSString *itemKey in post.items) {
//		[[[[[DataManager sharedInstance] refDatabase] child:@"postItems"]child:itemKey] setValue:nil];
//		//[[[[[DataManager sharedInstance] refStorage] child:@"assets"] child:post.key] deleteWithCompletion:nil];
//	}
	
	//delete poll
	[[[[[DataManager sharedInstance] refDatabase] child:@"posts"]child:post.key] setValue:nil withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		//[self.navigationController popViewControllerAnimated:YES];
		if(_onCompletion){
			_onCompletion(error,ref);
		}
	}];
}

@end
