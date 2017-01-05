//
//  BRBaseXibControl.m
//
//  Created by Edward Kim on 3/30/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "BRBaseXibView.h"

@implementation BRBaseXibView

- (instancetype)init
{
    if (self = [super init]) {
        
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

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

+ (UIView*)loadViewFromXib
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle];
    return  [nib instantiateWithOwner:self options:nil][0];
}

- (UIView*)loadViewFromXib:(Class)class
{
    NSBundle *bundle = [NSBundle bundleForClass:class];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(class) bundle:bundle];
    return  [nib instantiateWithOwner:self options:nil][0];
}

- (void)setup
{
    for (UIView *view in self.subviews){
        [view removeFromSuperview];
    }
    
    _view = [self loadViewFromXib:[self class]];
    
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        self.frame = _view.frame;
    }else{
        _view.frame = self.bounds;
    }
    
    //[self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_view];
    
    [_view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]setActive:YES];
    [[_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]setActive:YES];
    [[_view.topAnchor constraintEqualToAnchor:self.topAnchor]setActive:YES];
    [[_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]setActive:YES];
}

@end
