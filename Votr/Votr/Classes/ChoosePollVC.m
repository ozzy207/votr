//
//  ChoosePollVC.m
//  Votr
//
//  Created by tmaas510 on 18/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "ChoosePollVC.h"

@interface ChoosePollVC () {
    IBOutlet UILabel *titleLbl;
    IBOutlet UIImageView *avatarImg;
    IBOutlet UILabel *usernameLbl;
    IBOutlet UIImageView *firstImg;
    IBOutlet UIImageView *secondImg;
    
    IBOutlet UILabel *detailLbl1;
    IBOutlet UILabel *detailLbl2;
    IBOutlet UIButton *chooseBtn1;
    IBOutlet UIButton *chooseBtn2;
}

@end

@implementation ChoosePollVC
@synthesize obj;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self initUIwithPollData];
    
    avatarImg.layer.cornerRadius = 10;
    avatarImg.layer.masksToBounds = YES;
    [Utils CustomiseViewWithoutBorder:chooseBtn1];
    [Utils CustomiseViewWithoutBorder:chooseBtn2];
}

-(void) initUIwithPollData {
    
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj[kPoster];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    usernameLbl.text = user.username;
                    PFFile *file = user[kAvatar];
                    if(file != nil){
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if(error== nil && data != nil){
                                avatarImg.image = [UIImage imageWithData:data];
                            }
                        }];
                    }
                }
            }];
            
            titleLbl.text = obj[kTitle];
            detailLbl1.text = obj[kTitle1];
            detailLbl2.text = obj[kTitle2];
            
            PFFile *file1 = obj[kThumb1];
            if(file1 != nil){
                [file1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        firstImg.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
            PFFile *file2 = obj[kThumb2];
            if(file2 != nil){
                [file2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        secondImg.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)navBackbuttonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)navSkipButtonAction:(id)sender {
    
}

- (IBAction)chooseButtonAction:(UIButton *)sender {
    int votenum = [obj[kCountVote] intValue];
    int votenum1 = [obj[kCountVote1] intValue];
    int votenum2 = [obj[kCountVote2] intValue];
    
    [ProgressHUD show:@"saving..." Interaction:NO];
    
    if (sender.tag == 1) {
        votenum1 = votenum1 + 1;
    } else {
        votenum2 = votenum2 + 1;
    }
    
    PFObject *obj1 = [PFObject objectWithClassName:vClass_Vote];
    obj1[kUser] = [PFUser currentUser];
    obj1[kPoll] = obj;
    obj1[kVoted] = [NSNumber numberWithInteger:sender.tag];
    
    [obj1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            [ProgressHUD dismiss];
            [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
        }else{
            obj[kCountVote]     = [NSNumber numberWithInt:votenum];
            obj[kCountVote1]     = [NSNumber numberWithInt:votenum1];
            obj[kCountVote2]     = [NSNumber numberWithInt:votenum2];
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [ProgressHUD dismiss];
                if(error){
                    [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
                }else{
                    NSLog(@"count numbers are updated!");
                }
            }];
        }
    }];
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
