//
//  Poll.h
//  Votr
//
//  Created by tmaas510 on 18/10/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *candiThum1;
@property (nonatomic, strong) NSString *candiTitle1;
@property (nonatomic, strong) UIImage *candiThum2;
@property (nonatomic, strong) NSString *candiTitle2;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
