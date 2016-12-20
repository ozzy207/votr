//
//  MainLoginViewController.m
//  Votr
//
//  Created by tmaas510 on 16/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "MainLoginViewController.h"

@interface MainLoginViewController () {

    IBOutlet UIView *facebookView;
    IBOutlet UIView *googleView;
    IBOutlet UIView *emailView;
    IBOutlet UIButton *createAccountBtn;
}

@end

@implementation MainLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils WhiteEdgeButton:facebookView];
    [Utils WhiteEdgeButton:googleView];
    [Utils WhiteEdgeButton:emailView];
    [Utils WhiteEdgeButton:createAccountBtn];

}

- (IBAction)googleBtnAction:(id)sender {
    //TODO google signup action
}

- (IBAction)facebookBtnAction:(id)sender {
    
    NSArray *permission = @[@"public_profile", @"email"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permission block:^(PFUser *user, NSError *error) {
        if (!user) {//not user
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [Utils createAlert:@"Error" withMessage:@"An error occurred in facebook login.\nPlease try again later."];
        } else if(user.isNew){ //new user
            NSLog(@"user = %@", user);
            NSLog(@"User signed up and logged in through Facebook!");
            [ProgressHUD show:@"" Interaction:NO];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                               parameters:@{@"fields":@"id, name, picture.type(small), email"}] //birthday
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if ([error.userInfo[FBSDKGraphRequestErrorGraphErrorCode] isEqual:@200]) {
                     [ProgressHUD dismiss];
                     NSLog(@"permission error");
                     [Utils createAlert:@"Error" withMessage:@"permission error"];
                 } else {
                     NSDictionary *userData = (NSDictionary*)result;
                     NSLog(@"userData = %@", userData);
                     
                     NSString *useremail = userData[@"email"];
                     NSString *name = userData[@"name"];
                     NSString *nickname = [name componentsSeparatedByString:@" "][0];
                     //get avatarImg
                     NSURL *pictureURL = [NSURL URLWithString:userData[@"picture"][@"data"][@"url"]];
                     NSData *data = [NSData dataWithContentsOfURL:pictureURL];
                     PFFile *file = [PFFile fileWithData:data];
                     
                     user.email = useremail;
                     user.username = nickname;
                     user[kAvatar] = file;
                     [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         [ProgressHUD dismiss];
                         if((succeeded == TRUE) && (error == nil)){
                             [self performSegueWithIdentifier:@"mainToTabSegueId" sender:self];
                         }else{
                             [Utils createAlert:@"Error" withMessage:@"An error occurred in facebook login.\nPlease try again later!"];
                         }
                     }];
                 }
             }];
        }else{ //already registered
            NSLog(@"User logged in through Facebook!");
            [self performSegueWithIdentifier:@"mainToTabSegueId" sender:self];
        }
    }]; //*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
