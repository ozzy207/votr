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

@end
