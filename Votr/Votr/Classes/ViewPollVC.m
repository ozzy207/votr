//
//  ViewPollVC.m
//  Votr
//
//  Created by tmaas510 on 20/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "ViewPollVC.h"

@interface ViewPollVC () <UIAlertViewDelegate>{
    IBOutlet UILabel *titleLbl;
    IBOutlet UIImageView *avatarImg;
    IBOutlet UILabel *usernameLbl;
    IBOutlet UIImageView *firstImg;
    IBOutlet UIImageView *secondImg;
    
    IBOutlet UILabel *detailLbl1;
    IBOutlet UILabel *detailLbl2;
    IBOutlet UIButton *chooseBtn1;
    IBOutlet UIButton *chooseBtn2;
    
    PFUser *user;
}

@end

@implementation ViewPollVC
@synthesize poll;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    avatarImg.layer.cornerRadius = 10;
    avatarImg.layer.masksToBounds = YES;
    [Utils CustomiseViewWithoutBorder:chooseBtn1];
    [Utils CustomiseViewWithoutBorder:chooseBtn2];
    
    titleLbl.text = poll.title;
    
    user = [ PFUser currentUser];
    usernameLbl.text = user.username;
    PFFile *file = user[kAvatar];
    if(file != nil){
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(error== nil && data != nil){
                avatarImg.image = [UIImage imageWithData:data];
            }
        }];
    }
    
    detailLbl1.text = poll.candiTitle1;
    detailLbl2.text = poll.candiTitle2;
    
    firstImg.image = poll.candiThum1;
    secondImg.image = poll.candiThum2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)goTabVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"tabVC"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    del.window.rootViewController = vc;
}

- (IBAction)navBackbuttonAction:(id)sender {
    [self goTabVC];
}

- (IBAction)navRightButtonAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Delete Poll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
        [query whereKey:kPoster equalTo:[PFUser currentUser]];
        [query whereKey:kTitle equalTo:poll.title];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object != nil) {
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                        [self goTabVC];
                    } else {
                        [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
                    }
                }];
            }
        }];
    }
}

- (IBAction)chooseButtonAction:(UIButton *)sender {
    //TODO
}

@end
