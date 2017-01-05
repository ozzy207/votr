//
//  BRImageView.m
//
//  Created by Edward Kim on 7/18/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "BRImageView.h"
#import "Branding.h"

@implementation BRImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame]) {
       //Some init code
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
       //Some init code
    }
    return self;
}

#pragma mark - Setters
- (void)setImageColor:(NSString *)imageColor
{
    _imageColor = imageColor;
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[[Branding shareInstance] color:imageColor]];
}

@end
