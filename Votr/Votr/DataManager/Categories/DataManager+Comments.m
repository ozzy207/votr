//
//  DataManager+Comments.m
//  Votr
//
//  Created by Edward Kim on 2/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+Comments.h"
#import "VTRComment.h"

@implementation DataManager (Comments)

- (FIRDatabaseReference*)newCommentReference
{
	FIRDatabaseReference *posts = [self.refDatabase child:@"comments"];
	return [posts childByAutoId];
}

- (FIRDatabaseReference*)saveComment:(VTRComment*)comment reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref))_onCompletion
{
	if (databaseRef == nil) {
		databaseRef = [self newCommentReference];
	}
	
	comment.key = databaseRef.key;
	
	[databaseRef updateChildValues:[comment dictionaryRepresentation] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if(_onCompletion){
			_onCompletion(error,ref);
		}
	}];
	
	return databaseRef;
}

- (void)submitComment:(NSString*)postKey
{
	[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:postKey] child:@"comments"];
}
@end
