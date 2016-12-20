//
//  EmailLoginViewController.m
//  Votr
//
//  Created by tmaas510 on 16/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "EmailLoginViewController.h"

@interface EmailLoginViewController () <UITextFieldDelegate> {
    IBOutlet UITextField *usernameFld;
    IBOutlet UITextField *pwdFld;
    IBOutlet UIView *usernameView;
    IBOutlet UIView *pwdView;
    IBOutlet UIButton *continueBtn;
    
}

@end

@implementation EmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This is template code for my device
    NSString* identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
     NSLog(@"identifier = %@", identifier);
//    if ([identifier isEqualToString:my_deviceID]) {
//        usernameFld.text = @"devor";
//        pwdFld.text = @"qwerqwer";
//    }
    ///////////////////////////////////////
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Actions

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goBtnAction:(UIButton *)sender {
    [self loginWithEmail];
}

-(void)loginWithEmail {
    //Check empty fields
    if ([usernameFld.text  isEqual: @""] || [pwdFld.text  isEqual: @""]) {
        [ProgressHUD showError:msg_e_fillAll];
        return;
    }
    
    //TODO: signin with backend
    [ProgressHUD show:@"" Interaction:NO];
    [PFUser logInWithUsernameInBackground:usernameFld.text password:pwdFld.text block:^(PFUser *user, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            [self performSegueWithIdentifier:@"goTabFromLoginId" sender:self];
        } else {
            [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
        }
    }];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    float keyboardHeigh = 216.0;
    float offset;
    if ([textField isEqual:pwdFld]) {
        UIView *currentView = pwdView;
        offset =  keyboardHeigh - (self.view.bounds.size.height - currentView.frame.origin.y - currentView.frame.size.height);
        NSLog(@"offset = %f", offset);
        if (offset > 0) {
            CGRect rect = CGRectMake(0, -offset - 20, self.view.frame.size.width, self.view.frame.size.height);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == usernameFld) {
        [pwdFld becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginWithEmail];
    }
    
    return YES;
}

@end
