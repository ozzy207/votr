//
//  InviteFollowingViewController.h
//  Votr
//
//  Created by Edward Kim on 3/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseQueryViewController.h"

@interface InviteFollowingViewController : BaseQueryViewController
@property (nonatomic, copy) void (^inviteUsers)(NSMutableDictionary *userIDs);
@property (nonatomic, strong) VTRPost *post;
@end
