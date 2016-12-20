//
//  Poll.m
//  Votr
//
//  Created by tmaas510 on 18/10/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "Poll.h"

@implementation Poll

- (instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if(self)
    {
        [self initPollData:dict];
    }
    return self;
}

- (void)initPollData:(NSDictionary *)dict {
    self.title = [dict objectForKey:kTitle];
    self.candiThum1 = [dict objectForKey:kThumb1];
    self.candiThum2 = [dict objectForKey:kThumb2];
    self.candiTitle1 = [dict objectForKey:kTitle1];
    self.candiTitle2 = [dict objectForKey:kTitle2];
}

@end
