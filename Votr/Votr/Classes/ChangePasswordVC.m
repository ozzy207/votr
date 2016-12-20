//
//  ChangePasswordVC.m
//  Votr
//
//  Created by tmaas510 on 20/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "ChangePasswordVC.h"

@interface ChangePasswordVC () <UITextFieldDelegate> {

    IBOutlet UITextField *currentpwdFld;
    IBOutlet UITextField *newPwdFld;
    IBOutlet UITextField *confirmPwdFld;
}

@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)navCancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)navDoneAction:(id)sender {
    PFUser *user = [PFUser currentUser];
    
    //check password
    if (![currentpwdFld.text isEqual:user.password]) {
        [ProgressHUD showError:msg_e_wrongPassword];
        return;
    }
    
    if (![newPwdFld.text isEqual:confirmPwdFld.text]) {
        [ProgressHUD showError:msg_e_wrongPassword];
        return;
    }
    
    user.password = newPwdFld.text;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [ProgressHUD dismiss];
        if(error){
            NSString *errorString = [error userInfo][@"error"];
            [Utils createAlert:@"Error" withMessage:errorString];
        } else {
            [ProgressHUD showSuccess:@"Success!"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == currentpwdFld) {
        [newPwdFld becomeFirstResponder];
    } else if(textField == newPwdFld) {
        [confirmPwdFld becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
