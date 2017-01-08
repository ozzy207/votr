//
//  DataManager.h
//  Votr
//
//  Created by Edward Kim on 1/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface DataManager : NSObject
@property (strong, nonatomic) FIRStorageReference *refStorage;
@property (strong, nonatomic) FIRDatabaseReference *refDatabase;

+ (instancetype)sharedInstance;

@end
