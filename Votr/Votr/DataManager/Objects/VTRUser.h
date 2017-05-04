//
//  VTRUser.h
//  Votr
//
//  Created by Edward Kim on 2/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRUser : BaseDataObject
@property (strong, nonatomic) NSMutableDictionary *postsVoted;
@property (strong, nonatomic) NSMutableDictionary *posts;
@property (strong, nonatomic) NSMutableDictionary *topics;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *photoPath;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSMutableDictionary *followers;
@property (strong, nonatomic) NSMutableDictionary *following;
@end
