//
//  Me.h
//  Votr
//
//  Created by tmaas510 on 18/10/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Me : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isAvatar;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) UIImage *avatar;

- (instancetype)initWithUsername:(NSString *)name withEmail:(NSString *)email entityId:(NSString*)userId;
-(void)setAvatarImage:(UIImage *)avatar;
-(void)updateName:(NSString *)name;

@end
