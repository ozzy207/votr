//
//  SignupViewController.m
//  Votr
//
//  Created by tmaas510 on 16/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController () <UITextFieldDelegate> {
    
    IBOutlet UITextField *usernameFld;
    IBOutlet UITextField *pwdFld;
    IBOutlet UITextField *repwdFld;
    
    IBOutlet UIView *usernameView;
    IBOutlet UIView *pwdView;
    IBOutlet UIView *repwdView;
    IBOutlet UIButton *continueBtn;
    
}

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils CustomiseViewWithoutBorder:usernameFld];
    [Utils CustomiseViewWithoutBorder:pwdFld];
    [Utils CustomiseViewWithoutBorder:repwdFld];
    [Utils CustomiseViewWithoutBorder:continueBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton Actions

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//Signup
- (IBAction)goBtnAction:(UIButton *)sender {
    /*
     check text fields validation
    */
    
    //Check empty fields
    if ([usernameFld.text  isEqual: @""] || [pwdFld.text  isEqual: @""] || [repwdFld.text  isEqual: @""]) {
        [ProgressHUD showError:msg_e_fillAll];
        return;
    }
    
    //check password
    if (![pwdFld.text isEqual:repwdFld.text]) {
        [ProgressHUD showError:msg_e_wrongPassword];
        return;
    }
    
    //TODO: signup with backend
    [ProgressHUD show:@"" Interaction:NO];
    
    PFUser *user = [PFUser user];
    user.username = usernameFld.text;
    user.password = pwdFld.text;
//    user.email = [NSString stringWithFormat:@"%@@votr.com", user.username];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [ProgressHUD dismiss];
        if(succeeded == YES && !error){
            NSLog(@"Signup Success!");
            //go HomeViewController
            [self goTopicsScreen];
        }else{
            NSString *errorString = [error userInfo][@"error"];
            [Utils createAlert:msg_e_error withMessage:errorString];
            return;
        }
    }];
}

-(void)goTopicsScreen {
    [self performSegueWithIdentifier:@"signupToTopicSegue" sender:self];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    float keyboardHeigh = 216.0;
    float offset;
    if ([textField isEqual:repwdFld]) {
        UIView *currentView = repwdView;
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
    
    if (textField == usernameFld) {
        [pwdFld becomeFirstResponder];
    } else if(textField == pwdFld) {
        [repwdFld becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
