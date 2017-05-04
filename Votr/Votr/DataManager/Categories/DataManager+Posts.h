//
//  DataManager+Post.h
//  Votr
//
//  Created by Edward Kim on 1/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
#import "VTRPost.h"
#import "VTRPostItem.h"

@interface DataManager (Posts)
- (FIRDatabaseReference*)newPostReference;
- (FIRDatabaseReference*)newPostItemReference;

- (FIRDatabaseReference*)pushPost:(VTRPost*)post reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError *  error, FIRDatabaseReference * ref))_onCompletion;
- (FIRDatabaseReference*)pushPostItem:(VTRPostItem*)postItem reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * error, FIRDatabaseReference * ref))_onCompletion;
- (void)searchPostTitle:(NSString*)title completion:(void(^)(NSArray * posts))_onCompletion;
- (void)votePostKey:(NSString*)postKey postItemIndex:(NSInteger)selectedIndex completion:(void(^)(FIRDataSnapshot * _Nullable snapshot))_onCompletion;
- (void)deletePost:(VTRPost*)post completion:(void(^)(NSError * error,FIRDatabaseReference * ref))_onCompletion;
@end
