//
//  Me.m
//  Votr
//
//  Created by tmaas510 on 18/10/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "Me.h"

@implementation Me

- (instancetype)initWithUsername:(NSString *)name withEmail:(NSString *)email entityId:(NSString*)userId{
    self = [super init];
    if(self)
    {
        self.userId = userId;
        self.name = name;
        self.email = email;
        self.nickname = [NSString stringWithFormat:@"@%@", name];
        self.isAvatar = NO;
    }
    return self;
}

-(void)setAvatarImage:(UIImage *)avatar {
    self.avatar = avatar;
    self.isAvatar = YES;
}

-(void)updateName:(NSString *)name{
    self.name = name;
    self.nickname = [NSString stringWithFormat:@"@%@", name];
}

@end
