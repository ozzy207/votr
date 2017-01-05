//
//  BRButton.h
//
//  Created by Edward Kim on 3/1/16.
//  Copyright © 2016 DEDStop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BRButton : UIButton
@property (strong, nonatomic) IBInspectable NSString *colorCode;
@property (strong, nonatomic) IBInspectable NSString *textColorCode;
@property (nonatomic) IBInspectable NSInteger sizeCode;
@property (nonatomic) IBInspectable NSInteger weightCode;
@property (nonatomic) IBInspectable BOOL outline;
@end
