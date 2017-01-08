//
//  Branding.h
//  Votr
//
//  Created by Edward Kim on 01/06/16.
//  Copyright © 2016 DEDStop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+constraints.h"

@interface Branding : NSObject

#pragma mark - Life Cycle
+ (instancetype)shareInstance;
-(void)intitialize;
#pragma mark - Color
- (UIColor*)color:(NSString*)code;
#pragma mark - Font
- (UIFont*)font:(NSInteger)code weight:(NSInteger)weightCode;


@end
