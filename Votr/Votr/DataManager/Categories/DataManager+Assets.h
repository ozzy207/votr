//
//  DataManager+Asset.h
//  Votr
//
//  Created by Edward Kim on 1/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"

@class VTRPostItem;

@interface DataManager (Assets)
- (void)storePostItems:(NSArray*)postItems linkToDatabaseReference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSArray *urls, NSError *error))_onCompletion;
- (BOOL)storePostItem:(VTRPostItem*)postItem linkToDatabaseReference:(FIRDatabaseReference*)databaseRef completion:(void(^)(FIRStorageMetadata *metadata, NSError *error))_onCompletion;
@end
