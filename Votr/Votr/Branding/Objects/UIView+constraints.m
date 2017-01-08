//
//  UIView+Constraints.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "UIView+constraints.h"

@implementation UIView (constraints)

- (void)constrainSubview:(UIView*)subView
{
	[subView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self setLayoutMargins:UIEdgeInsetsZero];
	NSDictionary *dict = NSDictionaryOfVariableBindings(subView);
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[subView]|" options:0 metrics:nil views:dict]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[subView]-|" options:0 metrics:nil views:dict]];
	
	[NSLayoutConstraint activateConstraints:self.constraints];
}

@end
