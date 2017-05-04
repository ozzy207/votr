//
//  DataManager+Tags.h
//  Votr
//
//  Created by Edward Kim on 1/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
#import "VTRTag.h"

@interface DataManager (Tags)

- (FIRDatabaseReference*)newTagReference;
- (FIRDatabaseReference*)pushTag:(VTRTag*)tag reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * error, FIRDatabaseReference * ref))_onCompletion;
- (NSDictionary*)pushTagStrings:(NSArray*)tagStrings reference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSError * error, FIRDatabaseReference * ref))_onCompletion;
- (void)searchTags:(NSString*)tag completion:(void(^)(NSArray *tags))_onCompletion;
@end
