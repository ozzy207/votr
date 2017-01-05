//
//  BRLabel.h
//
//  Created by Edward Kim on 3/1/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BRLabel : UILabel
@property (strong, nonatomic) IBInspectable NSString *colorCode;
@property (nonatomic) IBInspectable NSInteger sizeCode;
@property (nonatomic) IBInspectable NSInteger weightCode;
@end
