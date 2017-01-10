//
//  BRTextField.h
//
//  Created by Edward Kim on 6/24/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

IB_DESIGNABLE
@interface BRTextField : JVFloatLabeledTextField
@property (nonatomic) IBInspectable NSInteger	style;
- (void)showError:(NSString*)errorMessage;
- (void)clearError;
@end
