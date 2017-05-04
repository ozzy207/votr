//
//  BaseScrollViewController.m
//  Votr
//
//  Created by Edward Kim on 1/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseScrollView.h"

@interface BaseScrollView ()

@end

@implementation BaseScrollView


#pragma mark - Setup/Teardown

- (void)setup {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(instancetype)initWithFrame:(CGRect)frame {
	if ( !(self = [super initWithFrame:frame]) ) return nil;
	[self setup];
	return self;
}

-(void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

-(void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self TPKeyboardAvoiding_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
	[super setContentSize:contentSize];
	[self TPKeyboardAvoiding_updateFromContentSizeChange];
}

- (void)contentSizeToFit {
	self.contentSize = [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
}

- (BOOL)focusNextTextField {
	return [self TPKeyboardAvoiding_focusNextTextField];
	
}
- (void)scrollToActiveTextField {
	return [self TPKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events

-(void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	if ( !newSuperview ) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[[self TPKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
	[super touchesEnded:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ( ![self focusNextTextField] ) {
		[textField resignFirstResponder];
	}
	return YES;
}

-(void)layoutSubviews {
	[super layoutSubviews];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
	[self performSelector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

@end