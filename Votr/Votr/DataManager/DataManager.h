//
//  DataManager.h
//  Votr
//
//  Created by Edward Kim on 1/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
#import "VTRUser.h"

#define WEB_API_KEY @"AIzaSyCDFNhQs5azFWESVVjx7rjkg2O34zuzPy0"
//AIzaSyDaUv2pueITb8Xd-2DJvx8HrSEAYJe4-Jc
#define URLSCHEME @"com.votr.invite"
#define FIREBASE_URL @"https://votr2-51a84.firebaseapp.com"

@interface DataManager : NSObject
@property (nonatomic, strong) void (^uploadStorageTaskProgress)(double progress,FIRStorageTaskSnapshot *snapshot);
@property (nonatomic, strong) void (^uploadStorageTaskComplete)(NSArray *snapshots);
@property (nonatomic, strong) void (^uploadStorageTaskError)(FIRStorageTaskSnapshot* snapshot);

@property (strong, nonatomic) FIRStorageReference *refStorage;
@property (strong, nonatomic) FIRDatabaseReference *refDatabase;
@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) NSMutableArray *snapshots;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableDictionary *tags;
@property (strong, nonatomic) VTRUser *user;
@property (nonatomic) NSInteger maxCacheSize;
+ (instancetype)sharedInstance;
- (void)initialize;
@end
