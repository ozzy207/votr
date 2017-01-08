//
//  BRSelectionImageView.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRSelectionImageView.h"
#import "Branding.h"

@interface BRSelectionImageView ()
@property (strong, nonatomic) UIImageView *checkMark;
@end

@implementation BRSelectionImageView

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

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.checkMark setAlpha:self.isSelected];
}

- (void)setup
{
	if (self.checkMark == nil) {
		self.checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Check"]];
		[self.checkMark setContentMode:UIViewContentModeCenter];
		[self.checkMark setTintColor:[[Branding shareInstance] color:@"K"]];
		[self.checkMark setUserInteractionEnabled:NO];
		[self.checkMark setAlpha:0];
		[self.checkMark setBackgroundColor:[[[Branding shareInstance] color:@"G"] colorWithAlphaComponent:0.8]];
		[self addSubview:self.checkMark];
		[self constrainSubview:self.checkMark];
	}
}

- (void)setIsSelected:(Boolean)isSelected
{
	_isSelected = isSelected;
	[self.checkMark setAlpha:self.isSelected];
}

@end
