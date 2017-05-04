//
//  VTRPoll.h
//  Votr
//
//  Created by Edward Kim on 1/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRPost : BaseDataObject
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSMutableDictionary *allowedUsers;
@property (nonatomic) BOOL isPrivate;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSDictionary *tags;
@property (strong, nonatomic) NSString *messageKey;
@property (strong, nonatomic) NSDictionary *votes;
@property (strong, nonatomic) NSDictionary *comments;
@end
