//
//  DataManager+Topics.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+Topics.h"

@implementation DataManager (Topics)


- (void)allTopics:(void(^)(NSArray *topics))_onCompletion
{
	FIRDatabaseReference *topics = [self.refDatabase child:@"topics"];
	[topics observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		//NSLog(@"%@",snapshot);
		
		NSMutableArray *array = [NSMutableArray new];
		//Dictionary
		for (NSString *key in [snapshot.value allKeys]) {
			NSDictionary *dict = [snapshot.value objectForKey:key];
			[array addObject:[VTRTopic instanceWithKey:key title:dict[@"title"]]];
		}
		dispatch_async(dispatch_get_main_queue(), ^(){
			_onCompletion(array);
		});
		
	}];
	
}

- (void)userTopics:(NSString*)userId onCompletion:(void(^)(NSArray *topics))_onCompletion
{
	FIRDatabaseReference *users = [self.refDatabase child:@"users"];
	FIRDatabaseReference *user = [users child:userId];
	if (user){
		[[user child:@"topics"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
			_onCompletion(snapshot.value);
		}];
	}
	
}

//- (void)saveUserTopics:(FIRUser*)user topics:(NSArray*)topics onCompletion:(void(^)(NSError *error, FIRDatabaseReference  *_Nonnull ref))_onCompletion
//{
//	[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:user.uid] updateChildValues:@{@"topics": topics} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//		_onCompletion(error,ref);
//	}];
//	 
//	 
//	 /*setValue:@{@"topics": topics} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * ref) {
//		 _onCompletion(error,ref);
//	 }];*/
//}


- (FIRStorageReference*)refStorageTopics
{
	return [self.refStorage child:@"topics"];
}
@end
