//
//  BRbel.m
//
//  Created by Edward Kim on 3/1/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "BRLabel.h"
#import "Branding.h"

@implementation BRLabel

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

- (void)setup
{
    [self setWeightCode:3];
    [self setSizeCode:0];
}

#pragma mark - Setters
- (void)setColorCode:(NSString *)colorCode
{
    _colorCode = colorCode;
    [self setTextColor:[[Branding shareInstance] color:colorCode]];
}

- (void)setSizeCode:(NSInteger)sizeCode andWeightCode:(NSInteger)weightCode
{
    self.sizeCode = sizeCode;
    self.weightCode = weightCode;
    [self setFont:[[Branding shareInstance] font:sizeCode weight:weightCode]];
}

- (void)setSizeCode:(NSInteger)sizeCode
{
    _sizeCode = sizeCode;
    [self setFont:[[Branding shareInstance] font:sizeCode weight:_weightCode]];
}

- (void)setWeightCode:(NSInteger)weightCode
{
    _weightCode = weightCode;
    [self setFont:[[Branding shareInstance] font:_sizeCode weight:weightCode]];
}

@end
