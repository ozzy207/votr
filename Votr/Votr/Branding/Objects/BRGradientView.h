//
//  BRGradientView.h
//  Votr
//
//  Created by Edward Kim on 1/4/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BRGradientView : UIView
@property (strong, nonatomic) IBInspectable NSString *colorCode1;
@property (strong, nonatomic) IBInspectable NSString *colorCode2;
@property (nonatomic) IBInspectable CGFloat backgroundAlpha;
@end
