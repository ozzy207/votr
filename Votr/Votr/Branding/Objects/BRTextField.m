//
//  BRTextField.m
//
//  Created by Edward Kim on 6/24/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "BRTextField.h"
@interface BRTextField()
@property(nonatomic,copy)NSString *placeHolderCache;
@end

@implementation BRTextField

#pragma mark - Life Cycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if(self.style == 1){
		[self setFont:[[Branding shareInstance] font:1 weight:4]];
		[self setTintColor:[UIColor lightGrayColor]];
		[self setFloatingLabelYPadding:3];
		[self setFloatingLabelTextColor:[[Branding shareInstance] color:@"G"]];
		[self setFloatingLabelActiveTextColor:[[Branding shareInstance] color:@"G"]];
	}
}

#pragma mark - Error
- (void)showError:(NSString*)errorMessage
{
    //if ([NSString notNull:errorMessage]) {
        [self setPlaceHolderCache:self.placeholder];
        [self setPlaceholder:errorMessage];
    //}
    
    [self setText:nil];
    [self updateDisplayWithError:YES];
}

- (void)clearError
{
    //if ([NSString notNull:self.placeHolderCache]) {
        [self setPlaceholder:self.placeHolderCache];
    //}
    
    [self updateDisplayWithError:NO];
}

- (void)updateDisplayWithError:(BOOL)error
{
    if (error) {
        [self setRightViewMode:UITextFieldViewModeAlways];
        [self setRightView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Asterisk"]]];
    }else{
        [self setRightView:nil];
    }
}

#pragma mark - RightView
- (CGRect) rightViewRectForBounds:(CGRect)bounds
{
    
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= 10;
    return textRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
	if (self.style == 1) {
		return CGRectInset(bounds, 8, 8);
	}
	return [super textRectForBounds:bounds];
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
	if (self.style == 1) {
		return CGRectInset(bounds, 8, 8);
	}
	return [super textRectForBounds:bounds];
}

- (void)drawRect:(CGRect)rect
{
	if (self.style == 1) {
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(0.0, 0.0)];
		[path addLineToPoint:CGPointMake(self.frame.size.width, 0.0)];
		[path moveToPoint:CGPointMake(0.0, self.frame.size.height)];
		[path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
		path.lineWidth = 1;
		[[[Branding shareInstance] color:@"M"] setStroke];
		[path stroke];
	}
}

@end
