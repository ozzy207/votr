//
//  DataManager+Topics.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"
#import "VTRTopic.h"
@interface DataManager (Topics)
- (void)allTopics:(void(^)(NSArray *topics))_onCompletion;
- (FIRStorageReference*)refStorageTopics;
- (void)userTopics:(NSString*)userId onCompletion:(void(^)(NSArray *topics))_onCompletion;
- (void)saveUserTopics:(FIRUser*)user topics:(NSArray*)topics onCompletion:(void(^)(NSError *error, FIRDatabaseReference  *ref))_onCompletion;
@end
