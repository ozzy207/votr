//
//  BRGradientView.m
//  Votr
//
//  Created by Edward Kim on 1/4/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRGradientView.h"
#import "Branding.h"

@interface BRGradientView()
@property (strong, nonatomic) CAGradientLayer *gradient;
@end

@implementation BRGradientView

- (instancetype)initWithFrame:(CGRect)frame
{
	if ( self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	[(CAGradientLayer*)self.layer setColors:@[(id)[[[[Branding shareInstance] color:self.colorCode1] colorWithAlphaComponent:self.backgroundAlpha] CGColor], (id)[[[[Branding shareInstance] color:self.colorCode2] colorWithAlphaComponent:self.backgroundAlpha] CGColor]]];
}
//
- (void)setup
{
	_backgroundAlpha = 1.0;
}
//
//#pragma mark - Setters
+ (Class)layerClass
{
	return [CAGradientLayer class];
}



@end
