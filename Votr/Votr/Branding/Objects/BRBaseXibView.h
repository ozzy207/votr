//
//  BRBaseXibControl.h
//
//  Created by Edward Kim on 3/30/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BRBaseXibView : UIView
@property (strong, nonatomic) UIView *view;
+ (UIView*)loadViewFromXib;
- (void)setup;
@end
