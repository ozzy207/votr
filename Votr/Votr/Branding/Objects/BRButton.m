//
//  BRButton.m
//
//  Created by Edward Kim on 3/1/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "BRButton.h"
#import "Branding.h"

@implementation BRButton

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
	if (self.outline) {
		self.layer.borderWidth = 1;
		self.layer.borderColor = [[Branding shareInstance] color:self.colorCode].CGColor;
		self.backgroundColor = [UIColor clearColor];
		[self.titleLabel setNumberOfLines:0];
		[self.titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
	}else{
		self.layer.borderWidth = 0;
		self.layer.borderColor = [UIColor clearColor].CGColor;
		[self setBackgroundColor:[[Branding shareInstance] color:self.colorCode]];
		[self.titleLabel setNumberOfLines:1];
		[self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	
	//[self setTitleColor:[[Branding shareInstance] color:self.textColorCode] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
	[self.titleLabel setFont:[[Branding shareInstance] font:self.sizeCode weight:self.weightCode]];
	
}

- (void)setup
{
    [self.layer setCornerRadius:4];
    [self setClipsToBounds:YES];
}

#pragma mark - Setters
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.alpha = enabled ? 1.0:0.4;
}

//-(CGSize)intrinsicContentSize
//{
//    return CGSizeMake(self.frame.size.width, self.titleLabel.frame.size.height);
//}

- (void)setTextColorCode:(NSString *)textColorCode
{
	_textColorCode = textColorCode;
	[self setTitleColor:[[Branding shareInstance] color:textColorCode] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
	
}

@end
