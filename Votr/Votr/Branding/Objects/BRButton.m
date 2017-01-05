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

- (void)setup
{
    [self.layer setCornerRadius:5];
    [self setClipsToBounds:YES];
}

#pragma mark - Setters
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.alpha = enabled ? 1.0:0.4;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    //UIColor *color = [[GTBranding shareInstance] color:highlighted?@"A":(self.outline?nil:_colorCode)];
    //[self setBackgroundColor:color];
}

//-(CGSize)intrinsicContentSize
//{
//    return CGSizeMake(self.frame.size.width, self.titleLabel.frame.size.height);
//}

- (void)setOutline:(BOOL)outline
{
    _outline = outline;
    if (outline) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[Branding shareInstance] color:_colorCode].CGColor;
        self.backgroundColor = [UIColor clearColor];
        [self.titleLabel setNumberOfLines:0];
        [self.titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [self setColorCode:_colorCode];
        
        [self.titleLabel setNumberOfLines:1];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    }
}

- (void)setTextColorCode:(NSString *)textColorCode
{
    _textColorCode = textColorCode;
    [self setTitleColor:[[Branding shareInstance] color:textColorCode] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];

}

- (void)setColorCode:(NSString *)colorCode
{
    _colorCode = colorCode;
    [self setBackgroundColor:[[Branding shareInstance] color:colorCode]];
}

- (void)setSizeCode:(NSInteger)sizeCode andWeightCode:(NSInteger)weightCode
{
    self.sizeCode = sizeCode;
    self.weightCode = weightCode;
    [self.titleLabel setFont:[[Branding shareInstance] font:sizeCode weight:weightCode]];
}

- (void)setSizeCode:(NSInteger)sizeCode
{
    _sizeCode = sizeCode;
    [self.titleLabel setFont:[[Branding shareInstance] font:sizeCode weight:_weightCode]];
}

- (void)setWeightCode:(NSInteger)weightCode
{
    _weightCode = weightCode;
    [self.titleLabel setFont:[[Branding shareInstance] font:_sizeCode weight:weightCode]];
}

@end
