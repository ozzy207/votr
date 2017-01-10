//
//  BRSegmentedControl.m
//  Votr
//
//  Created by Edward Kim on 1/9/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRSegmentedControl.h"

@implementation BRSegmentedControl


- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setTintColor:[[Branding shareInstance] color:self.colorCode]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
