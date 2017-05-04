//
//  DataManager+Asset.m
//  Votr
//
//  Created by Edward Kim on 1/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+Assets.h"
#import "VTRPostItem.h"
@implementation DataManager (Assets)

- (void)storePostItems:(NSArray*)postItems linkToDatabaseReference:(FIRDatabaseReference*)databaseRef completion:(void(^)(NSArray *urls, NSError *error))_onCompletion
{

	for (VTRPostItem *postItem in postItems) {
		[self storePostItem:postItem linkToDatabaseReference:databaseRef completion:^(FIRStorageMetadata *metadata, NSError *error) {
			if (error != nil) {
				_onCompletion(nil,error);
			}
		}];
	}
	
	self.uploadStorageTaskComplete = ^(NSArray *snapshots){
		_onCompletion([snapshots valueForKey:@"downloadURL"],nil);
		
	};
	
	self.uploadStorageTaskError = ^(FIRStorageTaskSnapshot *snapshot){
		if (snapshot.error != nil) {
			_onCompletion(nil,snapshot.error);
		}
	};
}

- (BOOL)storePostItem:(VTRPostItem*)postItem linkToDatabaseReference:(FIRDatabaseReference*)databaseRef completion:(void(^)(FIRStorageMetadata *metadata, NSError *error))_onCompletion
{
	if (postItem == nil || databaseRef == nil) {
		return NO;
	}
	
	if (postItem.url == nil && postItem.data == nil) {
		return NO;
	}
	
	//Assume if have URL it is a web url or a file url
	if(postItem.url && ![[NSFileManager defaultManager] fileExistsAtPath:[postItem.url path]]){
	
		//_onCompletion(postItem.url,nil);
		return NO;
	}
	
	FIRStorageReference *asset = [self.refStorage child:@"assets"];
	FIRStorageReference *newAsset = [asset child:databaseRef.key];
	FIRStorageReference *newUUID = [newAsset child:[[[NSUUID alloc] init] UUIDString]];
	
	FIRStorageUploadTask *task;
	if (postItem.url) {
		task = [newUUID putFile:postItem.url metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
			if (error != nil) {
				_onCompletion(nil,error);
			} else {
				_onCompletion(metadata,error);
			}
		}];
		
	}

	if (postItem.data) {
		task = [newUUID putData:postItem.data metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
			if (error != nil) {
				_onCompletion(nil,error);
			} else {
				_onCompletion(metadata,error);
			}
		}];
	}
	
	[self handleObservingTask:task];
	
	return YES;
}

- (void)handleObservingTask:(FIRStorageUploadTask*)task
{
	__weak typeof(self) weakSelf = self;
	[task observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
		// Download reported progress
		double percentComplete = (float)snapshot.progress.completedUnitCount / (float)snapshot.progress.totalUnitCount/[weakSelf.tasks count];
		dispatch_async(dispatch_get_main_queue(), ^(){
			if (weakSelf.uploadStorageTaskProgress) {
				weakSelf.uploadStorageTaskProgress(percentComplete,snapshot);
			}
			
		});
		
	}];
	
	[task observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
		[weakSelf.snapshots addObject:snapshot];
		NSMutableArray *removeArray = [NSMutableArray new];
		
		for (FIRStorageUploadTask *task in weakSelf.tasks) {
			if ([task.snapshot.metadata.path isEqualToString:snapshot.metadata.path]) {
				[removeArray addObject:task];
			}
		}

		[weakSelf.tasks removeObjectsInArray:removeArray];
		
		dispatch_async(dispatch_get_main_queue(), ^(){
			if (weakSelf.tasks.count == 0) {
				if (weakSelf.uploadStorageTaskComplete) {
					weakSelf.uploadStorageTaskComplete(weakSelf.tasks);
				}
			}
		});
	}];
	
	[task observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
		[weakSelf.tasks removeObject:snapshot.task];
		if (weakSelf.uploadStorageTaskError) {
			weakSelf.uploadStorageTaskError(snapshot);
		}
	}];
	
//	[task observeStatus:FIRStorageTaskStatusUnknown handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
//		[self.tasks removeObject:snapshot.task];
//		self.uploadStorageTaskError(snapshot);
//	}];
//	
	[self.tasks addObject:task];
}


@end
