//
//  BRView.m
//
//  Created by Edward Kim on 3/15/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "BRView.h"
#import "Branding.h"

@implementation BRView

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
    _backgroundAlpha = 1.0;
}

#pragma mark - Setters
- (void)setColorCode:(NSString *)colorCode
{
    _colorCode = colorCode;
    [self setBackgroundColor:[[[Branding shareInstance] color:colorCode] colorWithAlphaComponent:self.backgroundAlpha]];
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha
{
    _backgroundAlpha = backgroundAlpha;
    [self setBackgroundColor:[[[Branding shareInstance] color:self.colorCode] colorWithAlphaComponent:backgroundAlpha]];
}


@end
