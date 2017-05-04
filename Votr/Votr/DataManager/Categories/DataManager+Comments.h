//
//  DataManager+Comments.h
//  Votr
//
//  Created by Edward Kim on 2/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
@class VTRComment;

@interface DataManager (Comments)
- (FIRDatabaseReference*)newCommentReference;
- (FIRDatabaseReference*)saveComment:(VTRComment*)comment reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * error, FIRDatabaseReference * ref))_onCompletion;
@end