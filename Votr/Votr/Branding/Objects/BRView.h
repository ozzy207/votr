//
//  BRView.h
//
//  Created by Edward Kim on 3/15/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BRView:UIView
@property (strong, nonatomic) IBInspectable NSString *colorCode;
@property (nonatomic) IBInspectable CGFloat backgroundAlpha;
@end
