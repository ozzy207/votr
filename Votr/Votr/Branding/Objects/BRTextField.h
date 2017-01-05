//
//  BRTextField.h
//
//  Created by Edward Kim on 6/24/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRTextField : UITextField
- (void)showError:(NSString*)errorMessage;
- (void)clearError;
@end
