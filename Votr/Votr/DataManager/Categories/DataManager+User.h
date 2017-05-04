//
//  DataManager+User.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
@class VTRUser,VTRPost,VTRComment;

@interface DataManager (User)
- (void)updateUser:(VTRUser*)user onCompletion:(void(^)(NSError *error, FIRDatabaseReference  *ref))_onCompletion;
- (void)searchUsers:(NSString*)userName completion:(void(^)(NSArray *users))_onCompletion;

- (void)getUser:(NSString*)userID completion:(void(^)(VTRUser *user))_onCompletion;

@end
