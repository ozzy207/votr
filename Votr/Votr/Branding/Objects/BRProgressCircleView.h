//
//  BRCircleView.h
//  ViktoNote
//
//  Created by Edward Kim on 11/19/16.
//  Copyright © 2016 ViktoMedia. All rights reserved.
//

#import "BRView.h"

IB_DESIGNABLE
@interface BRProgressCircleView : UIView
@property (nonatomic) double percent;
@property (nonatomic) IBInspectable CGFloat lineWidth;
@property (nonatomic) IBInspectable CGFloat percentage;
@property (nonatomic, copy) void (^progress)(double percentage);
@property (nonatomic, copy) void (^completion)();
- (void)resetAnimation;
@end
