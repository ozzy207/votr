//
//  Branding.h
//
//  Created by Edward Kim on 4/23/16.
//  Copyright © 2016 IntBit Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Branding : NSObject

#pragma mark - Life Cycle
+ (instancetype)shareInstance;
-(void)intitialize;
#pragma mark - Color
- (UIColor*)color:(NSString*)code;
#pragma mark - Font
- (UIFont*)font:(NSInteger)code weight:(NSInteger)weightCode;


@end
