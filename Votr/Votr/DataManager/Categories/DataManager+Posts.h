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
- (FIRDatabaseReference*_Nullable)newPostReference;
- (FIRDatabaseReference*_Nullable)newPostItemReference;

- (FIRDatabaseReference*_Nullable)pushPost:(VTRPost* _Nullable )post reference:(FIRDatabaseReference* _Nullable )databaseRef completion:(void(^_Nullable)(NSError * _Nullable  error, FIRDatabaseReference * _Nullable ref))_onCompletion;
- (FIRDatabaseReference* _Nullable )pushPostItem:(VTRPostItem* _Nullable )postItem reference:(FIRDatabaseReference* _Nullable )databaseRef completion:(void(^ _Nullable )(NSError * _Nullable error, FIRDatabaseReference * _Nullable  ref))_onCompletion;
- (void)searchPostTitle:(NSString* _Nullable )title completion:(void(^ _Nullable )(NSArray * _Nullable  posts))_onCompletion;
- (void)votePostKey:(NSString* _Nullable )postKey postItemIndex:(NSInteger)selectedIndex completion:(void(^_Nullable)(FIRDataSnapshot * _Nullable snapshot))_onCompletion;
- (void)deletePost:(VTRPost*_Nonnull)post completion:(void(^_Nullable)(NSError * _Nullable error,FIRDatabaseReference * _Nullable ref))_onCompletion;
@end
