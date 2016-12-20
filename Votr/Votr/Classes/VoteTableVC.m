//
//  VoteTableVC.m
//  Votr
//
//  Created by tmaas510 on 30/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "VoteTableVC.h"

@interface VoteTableVC () <UITextViewDelegate>{

    IBOutlet UILabel *titleLbl;
    IBOutlet UISwitch *voteIncognitoSwitch;
    
    IBOutlet UIImageView *firstImg;
    IBOutlet UIImageView *secondImg;
    
    IBOutlet UILabel *detailLbl1;
    IBOutlet UIButton *chooseBtn1;
    
    IBOutlet UILabel *detailLbl2;
    IBOutlet UIButton *chooseBtn2;
    
    IBOutlet UITextView *txtview;
    
    BOOL isVoteIncognito;
    NSInteger selectedCandidate;
    NSString *placeholdTxt;
    int flag_save;
}

@end

@implementation VoteTableVC
@synthesize obj;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    placeholdTxt = @"Optional comments(140 character max):";
    [self addDoneButton];
    
    [self initUIwithPollData];
    selectedCandidate = 0;
    flag_save = 0;
}

-(void)addDoneButton {
    UIToolbar *m_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [m_toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDoneClick:)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    m_toolBar.items = [[NSArray alloc] initWithObjects:flexibleItem, barButtonDone, nil];
    barButtonDone.tintColor = [UIColor blackColor];
    txtview.inputAccessoryView = m_toolBar;
}

- (void)btnDoneClick:(id)sender{
    [txtview resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)voteIncognitoSwitchChanged:(UISwitch *)sender {
    
}

-(void) initUIwithPollData {
    
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj[kPoster];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    NSString *creator = [NSString stringWithFormat:@"@%@: ", user.username];
                    [Utils addAttributeStr:titleLbl withFirStr:creator secStr:obj[kTitle]];
                }
            }];
            
            detailLbl1.text = obj[kDescribe1];
            detailLbl2.text = obj[kDescribe2];
            
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

- (IBAction)chooseBtnAction:(UIButton *)sender {
    selectedCandidate = sender.tag;
    
    if (selectedCandidate == 1) {
        [chooseBtn1 setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
        [chooseBtn2 setImage:[UIImage imageNamed:@"btn_uncheck.png"] forState:UIControlStateNormal];
    } else {
        [chooseBtn1 setImage:[UIImage imageNamed:@"btn_uncheck.png"] forState:UIControlStateNormal];
        [chooseBtn2 setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
    }
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    // Your code here
    
    if ([textView.text isEqualToString:placeholdTxt]) {
        textView.text = @"";
    }
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeholdTxt;
    }
}

- (IBAction)saveAction:(id)sender {
    
    int votenum = [obj[kCountVote] intValue];
    int votenum1 = [obj[kCountVote1] intValue];
    int votenum2 = [obj[kCountVote2] intValue];
    int commentnum = [obj[kCountComment] intValue];
    
    [ProgressHUD show:@"saving..." Interaction:NO];
    
    if (selectedCandidate != 0) {
        //save vote
        votenum = votenum + 1;
        if (selectedCandidate == 1) {
            votenum1 = votenum1 + 1;
        } else {
            votenum2 = votenum2 + 1;
        }
        
        PFObject *obj1 = [PFObject objectWithClassName:vClass_Vote];
        obj1[kUser] = [PFUser currentUser];
        obj1[kPoll] = obj;
        obj1[kVoted] = [NSNumber numberWithInteger:selectedCandidate];
        
        [obj1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error){
                [ProgressHUD dismiss];
                [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
            }else{
                NSLog(@"vote number updated!");
                [self saveObjectFinished];
            }
        }];
    } else {
        [self saveObjectFinished];
    }
    
    if (![txtview.text isEqualToString:placeholdTxt]) {
        //save comment
        commentnum = commentnum + 1;
        
        PFObject *obj2 = [PFObject objectWithClassName:vClass_Comment];
        obj2[kUser] = [PFUser currentUser];
        obj2[kPoll] = obj;
        obj2[kComment] = txtview.text;
        obj2[kCountLike] = [NSNumber numberWithInt:0];
        [obj2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error){
                [ProgressHUD dismiss];
                [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
            }else{
                NSLog(@"comment number updated!");
                [self saveObjectFinished];
            }
        }];
    } else {
        [self saveObjectFinished];
    }
    
    obj[kCountVote]     = [NSNumber numberWithInt:votenum];
    obj[kCountVote1]     = [NSNumber numberWithInt:votenum1];
    obj[kCountVote2]     = [NSNumber numberWithInt:votenum2];
    obj[kCountComment]  = [NSNumber numberWithInt:commentnum];
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            [ProgressHUD dismiss];
            [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
        }else{
            NSLog(@"count numbers are updated!");
            [self saveObjectFinished];
        }
    }];
    
}

- (void) saveObjectFinished {
    flag_save = flag_save + 1;
    if (flag_save == 3) {
        [ProgressHUD dismiss];
        [ProgressHUD showSuccess:@"save success!"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
